#!/usr/bin/env ruby
require 'optparse'
require 'nokogiri'

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
  vue_file_content = File.read(vue_file)
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

# Function: create_vue_component_content
# Description: Creates the content of the Vue component file
# Parameters:
#   - vue_file: The path to the .vue file
#   - i18n_content: The content of the <i18n> section (String)
#   - script_content: The content of the <script> section (String)
#   - template_content: The content of the <template> section (String)
# Returns: The generated Vue.js component content
def create_vue_component_content(vue_file, i18n_content, script_content, template_content)
  vue_component = <<~VUE_TEMPLATE
    app.component('#{File.basename(vue_file, ".vue")}', {
      name: '#{File.basename(vue_file, ".vue")}',
      setup() {
        // Merge i18n language string of the component into the global i18n object
        const { t } = VueI18n.useI18n({});
        const mergeI18nLang = #{i18n_content.lstrip}
        let arrCountryCode = Object.keys(mergeI18nLang)
        arrCountryCode.forEach(cc => {
          i18n.global.mergeLocaleMessage([cc], mergeI18nLang[cc])
        });
        // Return section
        return { t }
      },
      #{script_content.gsub(/\A\s*export\s*default\s*\{\s*(.*)\s*}\s*\z/m, '\1').strip},
      template: '\\
        #{template_content.strip.gsub("\r\n", "\n").gsub("\n", "\\\n  ").gsub("'", "\\\\'")}'
    })
  VUE_TEMPLATE
  vue_component
end

# Function: write_vue_component_file
# Description: Writes the content of the Vue component file to a .js file if it has changed
# Parameters:
#   - vue_file: The path to the Vue component file (String)
#   - vue_component: The content of the Vue component file (String)
# Returns: None
def write_vue_component(vue_file, vue_component)
  vuejs_file_content = File.exist?(vue_file + '.js') ? File.read(vue_file + '.js') : ''
  File.write(vue_file + '.js', vue_component) if vuejs_file_content != vue_component
  puts " - Vue.js file created: #{File.basename(vue_file) + '.js'}"
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
  puts " - CSS file created: #{File.basename(vue_file) + '.js'} / #{File.basename(vue_file) + '.css'}"
end

# Function: create_vue_component_files
# Description: Creates component.vue.js files for each Vue component and generates corresponding .js and .css files
# Parameters:
#   - vue_base_dir: The base directory of Vue components (String)
#   - vue_components_list: The list of Vue component files (Array)
# Returns: None
def create_vue_component_files(vue_base_dir, vue_components_list)
  puts "\n=> Create vue components with vue-files of the directory: #{vue_base_dir}"
  vue_components_list.each do |vue_file|
    puts " - Create Component: #{vue_file.gsub(vue_base_dir, "")}.js"

    # Extract the template, script, style, and i18n sections from the Vue component file
    vue_sections = extract_vue_sections(vue_file)

    # Create vue content file
    vue_component = create_vue_component_content(vue_file, vue_sections[:i18n], vue_sections[:script], vue_sections[:template])
    
    # Write the Vue.js component content to a .js file if it has changed
    write_vue_component(vue_file, vue_component)

    # Write the CSS content to a .css file if it has changed
    write_css_file(vue_file, vue_sections[:style]) if vue_sections[:style].length > 0

  end
end

### Main script execution ###
options = parse_options

puts "*" * 50
puts "Vue 3 transformer started\n\n"

vue_base_dir = options[:path]
vue_components_list = search_vue_components(vue_base_dir)
create_vue_component_files(vue_base_dir, vue_components_list)

puts "*" * 50
puts "Vue 3 transformer finished"
puts "*" * 50
puts ""
