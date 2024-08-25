require 'optparse'
require 'fileutils'

# Function: parse_options
# Description: Parse command line options
# Parameters: None
# Returns:
#   - options (Hash): Parsed options
def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} -p <path>"

    opts.on "-p PATH", "--path PATH", "Path where CSS files are searched." do |p|
      options[:path] = File.expand_path(p)
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

# Function: search_css_files
# Description: Search for unminified CSS files in the specified directory
# Parameters:
#   - css_base_directory (String): Base directory to search for CSS files
# Returns:
#   - found_css_files (Array): List of found unminified CSS files
def search_css_files(css_base_directory)
  puts "\n=> Search for unminified CSS files in folder: #{css_base_directory}"
  found_css_files = []
  Dir[css_base_directory+'/**/*.css'].each do |found_css_file|
    if !found_css_file.include?(".min.css")
      puts " - Unminified CSS file found: ..#{found_css_file.gsub(css_base_directory, "")}"
      found_css_files.push(found_css_file)
    end
  end
  found_css_files
end

# Function: create_minify_script
# Description: Create a minify script file for Node.js
# Parameters:
#   - script_base_dir (String): Base directory of the script
#   - found_css_files (Array): List of found unminified CSS files
# Returns: None
def create_minify_script(script_base_dir, found_css_files)
  puts "=> Create minify script file for Node.js."
  js_minify_script = <<~MINIFY_HEAD_END
    const fs = require('fs');
    var CleanCSS = require('clean-css');
    const path = require('path');

    var CleanCSS_options = {
      level: 1
    };

    var css_file_list = [];
    var css_file_content = [];
  MINIFY_HEAD_END

  script_css_file_list = ""
  found_css_files.each do |filename|
    script_css_file_list += "css_file_list.push(`#{filename[0...-4]}`)\n"
  end

  js_minify_script += <<~MINIFY_COMP_END
    #{script_css_file_list}
    css_file_list.forEach(filename => {
      // read .css file
      let file_content = fs.readFileSync(filename+".css", "utf8")

      // execute minify command via CleanCSS
      var output = new CleanCSS(CleanCSS_options).minify(file_content);

      // write result to .min.css file
      fs.writeFile(filename+".min.css", output.styles, (err) => {
        if (err)
          console.log(" - Node.js Error: Can not write file: " + filename + ".css Error: " + err);
        else {
          console.log(" - Node.js Info: File " + filename + ".min.css written successfully");
        }
      });
    });
  MINIFY_COMP_END

  tmp_dir = "#{script_base_dir}/tmp"
  FileUtils.mkdir_p(tmp_dir) unless File.exist?(tmp_dir)
  File.write("#{tmp_dir}/node_css_minify_script.js", js_minify_script)
  puts " - Write minify script: #{tmp_dir}/node_css_minify_script.js"
end

# Function: execute_minify_script
# Description: Execute the Node.js minify script
# Parameters:
#   - script_base_dir (String): Base directory of the script
# Returns: None
def execute_minify_script(script_base_dir)
  puts "=> Execute Node.js CSS Minifier script."
  execute_compiler_file = Thread.new do
    system('node "' + script_base_dir + '/tmp/node_css_minify_script.js"') # execute!
  end
  execute_compiler_file.join            # main program waiting for thread
  puts " - CSS Minifier script executed."
end

### Main script execution ###
script_base_dir = File.dirname(File.expand_path(__FILE__))
options = parse_options

puts "*" * 50
puts "CSS Minifier started\n\n"

css_base_directory = File.expand_path(options[:path])
found_css_files = search_css_files(css_base_directory)
create_minify_script(script_base_dir, found_css_files)
execute_minify_script(script_base_dir)

puts "*" * 50
puts "CSS Minifier finished"
puts "*" * 50
puts ""
