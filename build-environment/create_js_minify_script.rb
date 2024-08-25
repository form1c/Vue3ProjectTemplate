require 'optparse'
require 'fileutils'

# Function: parse_options
# Description: Parses command-line options
# Parameters: None
# Returns:
#   - options: A hash containing the parsed options
def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} -p <path>"

    opts.on "-p PATH", "--path PATH", "Path where JS files are searched." do |p|
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

# Function: search_js_files
# Description: Searches for unminified JS files in the specified directory
# Parameters:
#   - js_base_directory: The base directory to search for JS files
# Returns:
#   - found_js_files: An array of found unminified JS file paths
def search_js_files(js_base_directory)
  puts "\n=> Search for unminified JS files in folder: #{js_base_directory}"
  found_js_files = []
  Dir[js_base_directory + '/**/*.js'].each do |found_js_file|
    if !found_js_file.include?(".min.js")
      puts " - Unminified JS file found: ..#{found_js_file.gsub(js_base_directory, "")}"
      found_js_files.push(found_js_file)
	  end
  end
  found_js_files
end

# Function: create_minify_script
# Description: Creates a minify script file for Node.js
# Parameters:
#   - script_base_dir: The base directory of the script
#   - found_js_files: An array of found unminified JS file paths
# Returns: None
def create_minify_script(script_base_dir, found_js_files)
  puts "=> Create minify script file for Node.js."
  js_minify_script = <<~MINIFY_HEAD_END
  const fs = require('fs');
  var UglifyJS = require("uglify-js");

  var UglifyJS_options = {
    output: {
      // output options //
      //beautify: true
    },
    //compress: {
      // compress options //
    //}
    compress: true,
    mangle: true
  };

  var js_file_list = [];
  MINIFY_HEAD_END

  script_js_file_list = ""
  found_js_files.each do |filename|
    script_js_file_list += "js_file_list.push('#{filename[0...-3]}')\n"
  end

  js_minify_script += <<~MINIFY_COMP_END
  #{script_js_file_list}
  js_file_list.forEach(filename => {
    // read .fs file
    let file_content = fs.readFileSync(filename+".js", "utf8")

    // execute minify command via UglifyJS
    let result = UglifyJS.minify(file_content, UglifyJS_options);

    if(undefined == result.error) {
      console.log("   Info: Minify file: " + filename + ".js")
      // write result to .min.js file
      fs.writeFile(filename+".min.js", result.code, (err) => {
        if (err)
          console.log("Error: Can not write file: " + filename + ".js Error: " + err);
        else {
          console.log("   Info: File " + filename + ".min.js written successfully");
        }
      });
    } else
      console.log("Error: Can not minify file: " + result.error)
  });
  MINIFY_COMP_END

  tmp_dir = "#{script_base_dir}/tmp"
  FileUtils.mkdir_p(tmp_dir) unless File.exist?(tmp_dir)
  File.write("#{tmp_dir}/node_js_minify_script.js", js_minify_script)
  puts " - Write minify script: #{tmp_dir}/node_js_minify_script.js"
end

# Function: execute_minify_script
# Description: Executes the Node.js minify script
# Parameters:
#   - script_base_dir: The base directory of the script
# Returns: None
def execute_minify_script(script_base_dir)
  puts "=> Execute Node.js minify script."
  execute_compiler_file = Thread.new do
    system('node "' + script_base_dir + '/tmp/node_js_minify_script.js"')
	end
  execute_compiler_file.join # main program waiting for thread
  puts " - Minify script executed."
end

### Main script execution ###
script_base_dir = File.dirname(File.expand_path(__FILE__))
options = parse_options

puts "*" * 50
puts "JS Minifier started\n\n"

js_base_directory = File.expand_path(options[:path])
found_js_files = search_js_files(js_base_directory)
create_minify_script(script_base_dir, found_js_files)
execute_minify_script(script_base_dir)

puts "*" * 50
puts "JS Minifier finished"
puts "*" * 50
puts ""
