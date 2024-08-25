require 'optparse'
require 'pp'
require 'json'
require 'nokogiri'

# Function: script_base_dir
# Description: Returns the base directory of the script
# Parameters: None
# Returns: The base directory of the script (String)
def script_base_dir
  File.dirname(File.expand_path(__FILE__))
end

# Function: parse_options
# Description: Parses command-line options using OptionParser
# Parameters: None
# Returns: A hash containing the parsed options
def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{File.basename __FILE__} -p <path>"

    opts.on("-p", "--path PATH", "Path where vue files are searched.") do |path|
      options[:path] = path
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end.parse!

  unless options[:path]
    puts "Error: Path to the directory is required."
    exit 1
  end

  options
end

# Function: search_vue_components
# Description: Searches for Vue components and checks their names
# Parameters:
#   - vue_base_dir: The base directory to search for Vue components (String)
# Returns: The list of Vue component files (Array)
def search_vue_components(vue_base_dir)
  puts "=> Search for Vue 3 component files in folder: #{vue_base_dir}"
  vue_components_list = []
  Dir[File.expand_path(vue_base_dir)+'/**/*.vue'].each do |vue_file|
    puts " - Component found: ..#{vue_file.gsub(vue_base_dir, "")}"
    vue_components_list.push(vue_file)
  end
  vue_components_list
end

# Function: create_compiler_script
# Description: Creates a Vue 3 compiler file for Node.js
# Parameters:
#   - vue_components_list: The list of Vue component files (Array)
# Returns: The Path to the JavaScript compiler script
def create_compiler_script(vue_components_list)
  puts "=> Create Vue 3 sfc compiler script."
  js_compile_script = <<~COMPILER_FILE_START
    const { parse, compileTemplate, compileScript, compileStyle } = require('@vue/compiler-sfc');
    const crypto = require('crypto');
    const path = require('path');
    const fs = require('fs');
    var vue_file_list = []
  COMPILER_FILE_START

  vue_components_list.each do |vue_file|
    js_compile_script += <<~COMPILER_FILES
      vue_file_list.push('#{vue_file}')
      COMPILER_FILES
  end

  js_compile_script += <<~COMPILER_FILE_END
  vue_file_list.forEach(vue_filename => {
    // Read in JS file
    let file_content = fs.readFileSync(vue_filename, "utf8")
    // Create a md5 as id via the filename
    const fileId = crypto.createHash('md5').update(vue_filename).digest('hex');
    // parse template out of the vue-file
    let { descriptor, errors } = parse(file_content);
    const vue_template = descriptor.template.content;
    // Create compiler options
    let options = {
        filename: vue_filename,
        id: fileId,
        isProd: true,
        source: vue_template,
        compilerOptions: {
            comments: false
        }
    }
    // Compile vue-template file
    let template = compileTemplate(options);
    let templateCode = template.code;
    fs.writeFile(vue_filename+".render", templateCode, (err) => {
      if (err)
        console.log("Error: Can not write file: " + vue_filename + ".render Error: " + err);
      else {
        console.log("   Info: File " + vue_filename + ".render written successfully");
      }
    });
  });
  COMPILER_FILE_END

  # Save the compiler script
  compiler_script_path = script_base_dir + '/tmp/node_vue3_sfc_compiler_script.js'
  Dir.mkdir script_base_dir + '/tmp/' unless File.exists?(script_base_dir + '/tmp/')
  File.write compiler_script_path, js_compile_script

  compiler_script_path
end

# Function: execute_compiler_script
# Description: Executes the Node.js compiler file and compiles Vue 3 components
# Parameters:
#   - compiler_script_path: The path to the JavaScript compiler script (String)
# Returns: None
def execute_compiler_script(compiler_script_path)
  puts "=> Execute Vue 3 sfc compiler script."
  execute_compiler_file = Thread.new do
    system('node "' + compiler_script_path + '"') # execute!
  end
  execute_compiler_file.join # main program waiting for thread
  puts " - Compiler script executed."
end

# Function: parse_vue_imports
# Description: Parse global imports from the import line
# Parameters:
#   - vue_base_dir: The base directory of Vue components (String)
#   - vue_components_list: The list of Vue component files (Array)
# Returns: The array of global imports (Array)
def parse_vue_imports(vue_base_dir, vue_components_list)
  puts "=> Parse global imports"
  arr_global_imports = []
  vue_components_list.each do |vue_file|
    puts " - Parse ..#{vue_file.gsub(vue_base_dir, "")} file for imports."
    str_import_line = File.open(vue_file + ".render", &:readline) # The import line is the first line of the file
    arr_imports = str_import_line.split('import { ').last.split(' } from "vue"').first.split(',')

    arr_imports.each do |value|
      str_import_function = value.strip.gsub(/\s.+/, '')
      if !str_import_function.empty?
        arr_global_imports.push(str_import_function) unless arr_global_imports.include?(str_import_function)
      end
    end
  end

  arr_global_imports # Return the array of global imports
end

# Function: extract_vue_sections
# Description: Extracts the template, script, style, and i18n sections from a Vue component file
# Parameters:
#   - vue_file: The path to the Vue component file (String)
# Returns: A hash containing the extracted sections
#   - template: The content of the <template> section (String)
#   - script: The content of the <script> section (String)
#   - style: The content of the <style> section (String)
#   - i18n: The content of the <i18n> section (String)
def extract_vue_sections(vue_file)
  vue_file_content = File.read vue_file
  html = Nokogiri::HTML("<html><body>#{vue_file_content}</body></html>")

  # Extract the <template> section
  template = html.xpath("/html/body/template")
  raise "The vue-file '#{File.basename(vue_file)}' must contain exactly one <template> root element." if template.length != 1

  # Extract the <script> section
  script = html.xpath("/html/body/script")
  raise "The vue-file '#{File.basename(vue_file)}' must contain exactly one <script> root element." if script.length != 1

  # Extract the <style> section (optional)
  style = html.xpath("/html/body/style")
  raise "The vue-file '#{File.basename(vue_file)}' must contain no or one <style> root element." if style.length > 1

  # Extract the <i18n> section (optional)
  i18n = html.xpath("/html/body/i18n")
  raise "The vue-file '#{File.basename(vue_file)}' must contain no or one <i18n> root element." if i18n.length > 1

  # Extract the content of each section
  {
    template: template.first.to_s.gsub(/<template>(.*)<\/template>/m, '\1').strip,
    script: script.first.to_s.gsub(/<script>(.*)<\/script>/m, '\1').strip,
    style: style.length == 1 ? style.first.to_s.gsub(/<style>(.*)<\/style>/m, '\1').strip : "",
    i18n: i18n.length == 1 ? i18n.first.to_s.gsub(/<i18n>(.*)<\/i18n>/m, '\1').strip.gsub(/^/, "    ") : "{}"
  }
end

# Function: create_vue_component_files
# Description: Creates component.vue.js files for each Vue component
# Parameters:
#   - vue_base_dir: The base directory of Vue components (String)
#   - vue_components_list: The list of Vue component files (Array)
#   - arr_global_imports: The array of global imports (Array)
# Returns: None
def create_vue_component_files(vue_base_dir, vue_components_list, arr_global_imports)
  puts "\n=> Create vue components with vue-files of the directory: #{vue_base_dir}"
  vue_components_list.each do |vue_file|
    puts " - Create Component: #{vue_file.gsub(vue_base_dir, "")}.js"

    # Extract the template, script, style, and i18n sections from the Vue component file
    vue_sections = extract_vue_sections(vue_file)

    # Load vue render file
    vue_render_file = File.read vue_file + '.render'
    # Remove render file for next compile procedure
    File.delete(vue_file + '.render')

    # PREPARE RENDER CONSTS
    vue_render_const = prepare_render_consts(vue_render_file, arr_global_imports)

    # PREPARE RENDER FUNCTIONS
 	  # Parse vue render consts out of render file
    vue_render_function = prepare_render_function(vue_render_file, arr_global_imports)

    # Create vue content file
    vue_component = create_vue_component_content(vue_file, vue_render_const, vue_render_function, vue_sections[:i18n], vue_sections[:script])

    # Write the Vue.js component content to a .js file if it has changed
    write_vue_component_file(vue_file, vue_component)

    # Write the CSS content to a .css file if it has changed
    write_css_file(vue_file, vue_sections[:style]) if vue_sections[:style].length > 0

  end
end

# Function: prepare_render_consts
# Description: Prepares the render constants from the render file
# Parameters:
#   - vue_render_file: The content of the render file (String)
#   - arr_global_imports: The array of global imports (Array)
# Returns: The prepared render constants (String)
def prepare_render_consts(vue_render_file, arr_global_imports)
  # Parse vue render consts out of render file
  vue_render_const = vue_render_file.split('from "vue"').last.split('export function render').first.strip
  # Rename the render const names in the render const list from _hoisted_ to hoisted_ to avoid vue warning (because only internal vue variables should start with "_")
  vue_render_const.gsub!("_hoisted_", "r_itm_")
  # Rename the vue3 functions in the render consts list from _vue_function -> vue_function
  # Use arrGlobalImports list to know which functions need to be renamed.
  arr_global_imports.each do |item|
    vue_render_const.gsub!("_#{item}", "Vue.#{item}")
  end
  vue_render_const
end

# Function: prepare_render_function
# Description: Prepares the render function from the render file
# Parameters:
#   - vue_render_file: The content of the render file (String)
#   - arr_global_imports: The array of global imports (Array)
# Returns: The prepared render function (String)
def prepare_render_function(vue_render_file, arr_global_imports)
  # Parse vue render function out of render file
  vue_render_function = "render" + vue_render_file.split('export function render').last
  # Rename the render const names in the render function from _hoisted_ to this.hoisted_
  vue_render_function.gsub!("_hoisted_", "this.r_itm_")
  # Rename the vue3 functions in the render function from _vue_function -> vue_function
  # Use arrGlobalImports list to know which functions need to be renamed.
  arr_global_imports.each do |item|
    vue_render_function.gsub!("_#{item}", "Vue.#{item}")
  end
  vue_render_function
end

# Function: create_vue_component_content
# Description: Creates the content of the Vue component file
# Parameters:
#   - vue_file: The path to the Vue component file (String)
#   - vue_render_const: The prepared render constants (String)
#   - vue_render_function: The prepared render function (String)
#   - i18n_content: The content of the <i18n> section (String)
#   - script_content: The content of the <script> section (String)
# Returns: The content of the Vue component file (String)
def create_vue_component_content(vue_file, vue_render_const, vue_render_function, i18n_content, script_content)

  # Parse render const names to return them from the setup(...) function.
  vue_render_const_vars = vue_render_const.scan(/r_itm_\d*/m)

  vue_component = <<~VUE_TEMPLATE_END
  app.component('#{File.basename(vue_file,".vue")}', {
    name: '#{File.basename(vue_file,".vue")}',
    setup() {
      // Render consts
      #{vue_render_const}
      // Merge i18n language string of the component into the global i18n object
      const { t } = VueI18n.useI18n({});
      const mergeI18nLang = #{i18n_content.lstrip}
      let arrCountryCode = Object.keys(mergeI18nLang)
      arrCountryCode.forEach(cc => {
        i18n.global.mergeLocaleMessage([cc], mergeI18nLang[cc])
      });
      // Return section
      return {
  VUE_TEMPLATE_END
  temp_const = ""
  vue_render_const_vars.each do |item|
    temp_const += item + ", "
  end
  vue_component += <<~VUE_TEMPLATE_END
        t, #{temp_const[0..-3]}
      }
    },
    #{vue_render_function.gsub!("\n", "\n  ")},
    #{script_content.gsub(/\A\s*export\s*default\s*\{\s*(.*)\s*}\s*\z/m,'\1').strip}
  })
  VUE_TEMPLATE_END
  vue_component
end

# Function: write_vue_component_file
# Description: Writes the content of the Vue component file to a .js file if it has changed
# Parameters:
#   - vue_file: The path to the Vue component file (String)
#   - vue_component: The content of the Vue component file (String)
# Returns: None
def write_vue_component_file(vue_file, vue_component)
  vuejs_file_content = File.exist?(vue_file + '.js') ? File.read(vue_file + '.js') : ''
  File.write(vue_file + '.js', vue_component) if vuejs_file_content != vue_component
  puts "   => #{File.basename(vue_file)}.js file generated"
end

# Function: write_css_file
# Description: Writes the content of the <style> section to a .css file if it has changed
# Parameters:
#   - vue_file: The path to the Vue component file (String)
#   - style_content: The content of the <style> section (String)
# Returns: None
def write_css_file(vue_file, style_content)
  css_file_content = File.exist?(vue_file + '.css') ? File.read(vue_file + '.css') : ''
  File.write(vue_file + '.css', style_content) if css_file_content != style_content
  puts "   => #{File.basename(vue_file)}.css file generated" if style_content.length > 0
end


### Main script execution ###
options = parse_options

puts "*" * 50
puts "Vue 3 compiler started\n\n"

vue_base_dir = options[:path]
vue_components_list = search_vue_components(vue_base_dir)

compiler_script_path = create_compiler_script(vue_components_list)
execute_compiler_script(compiler_script_path)
arr_global_imports = parse_vue_imports(vue_base_dir, vue_components_list)

create_vue_component_files(vue_base_dir, vue_components_list, arr_global_imports)

puts "*" * 50
puts "Vue 3 compiler finished"
puts "*" * 50
puts ""
