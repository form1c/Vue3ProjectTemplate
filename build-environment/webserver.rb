#!/usr/bin/env ruby
require 'sinatra'
require 'pp'
require 'fileutils'

require_relative 'config.rb'

#####################################
### Sinatra                       ###
#####################################
set :bind, '0.0.0.0'
set :port, WEBSERVER_PORT
set :public_folder, WEBSITE_ROOT_PATH

# Function: get "/"
# Description: Handles the root route ("/") request
# Parameters: None
# Returns: The content of the index file (debug or release)
get "/" do
  build_debug() if RELEASE == false
  build_release() if RELEASE == true

  createLanguageFile()

  if MINIFY_FILES == true
    minifyFiles()
    return File.read("#{WEBSITE_INDEX_PATH.sub ".html",".min.html"}")
  else
    return File.read("#{WEBSITE_INDEX_PATH}")
  end
end

# Function: get "/*"
# Description: Handles requests for all other routes
# Parameters: None
# Returns: The content of the requested file
# get "/*" do
#   # only needed if :public_folder is not used
#   set_content_type request.path_info
#   File.binread "#{WEBSITE_ROOT_PATH}#{request.path_info}" # read binary -> important because of e.g. images
# end

# Function: set_content_type
# Description: Sets the content type based on the file extension
# Parameters:
#   - path: The file path
# Returns: None
def set_content_type(path)
  case File.extname(path)
  when ".js"
    content_type 'text/javascript'
  when ".html", ".htm"
    content_type 'text/html'
  when ".css"
    content_type 'text/css'
  when ".json"
    content_type 'application/json'
  when ".txt"
    content_type 'text/plain'
  when ".bmp"
    content_type 'image/bmp'
  when ".gif"
    content_type 'image/gif'
  when ".jpeg", ".jpg"
    content_type 'image/jpeg'
  when ".png"
    content_type 'image/png'
  when ".svg"
    content_type 'image/svg+xml'
  when ".woff"
    content_type 'font/woff'
  when ".woff2"
    content_type 'font/woff2'
  when ".ico"
    content_type 'image/vnd.microsoft.icon'
  end
end

#####################################
### Debug functions               ###
#####################################

# Function: build_debug
# Description: Builds the debug version of the project.
# Parameters: None
# Returns: None
def build_debug
  convertVue3JsDebugComponents()
end

# Function: convertVue3JsDebugComponents
# Description: The Ruby script creates the Vue 3 JavaScript components in the debug version.
# Parameters: None
# Returns: None
def convertVue3JsDebugComponents
  system("ruby",
  "#{BUILD_SOLUTION_PATH}/vue3-transform-debug.rb",
  "-p", "#{WEBSITE_VUE_PATH}")
end

#####################################
### Release functions             ###
#####################################

# Function: build_release
# Description: Builds the release version of the project.
# Parameters: None
# Returns: None
def build_release
  convertVue3JsReleaseComponents() 
end

# Function: convertVue3JsReleaseComponents
# Description: The Ruby script creates the Vue 3 JavaScript components in the release version.
# Parameters: None
# Returns: None
def convertVue3JsReleaseComponents
  system("ruby",
  "#{BUILD_SOLUTION_PATH}/vue3-compiler-release.rb",
  "-p", "#{WEBSITE_VUE_PATH}")
end

# Function: createLanguageFile
# Description: The Ruby script to export the i18n language strings of the vue-components.
# Parameters: None
# Returns: None
def createLanguageFile
  system("ruby",
  "#{BUILD_SOLUTION_PATH}/vue3-language-export.rb",
  "-p", "#{WEBSITE_VUE_PATH}")
end

# Function: removeCommentsFromHtmlFile
# Description: Removes comments from an HTML file.
# Parameters:
#   - html_content: The content of the HTML file
# Returns: None
def removeCommentsFromHtmlFile(html_content)
  html_content.gsub!(/(?=<!--)([\s\S]*?)-->/, "") # remove single and multiline HTML comments 
end

#####################################
### Minify functions              ###
#####################################

# Function: minifyFiles
# Description: The function calls all further minimizing functions.
# Parameters: None
# Returns: None
def minifyFiles()
  createMinifyScriptForJsFiles(WEBSITE_JS_PATH)
  createMinifyScriptForJsFiles(WEBSITE_VUE_PATH)

  createMinifyScriptForCssFiles(WEBSITE_CSS_PATH)
  createMinifyScriptForCssFiles(WEBSITE_VUE_PATH)

  includeMinifyFilesIntoHtmlFiles(WEBSITE_ROOT_PATH)
end

# Function: createMinifyScriptForJsFiles
# Description: The Ruby script creates a js minify script for UglifyJS.
# Parameters:
#   - path: The path to the JavaScript files
# Returns: None
def createMinifyScriptForJsFiles(path)
  system("ruby",
  "#{BUILD_SOLUTION_PATH}/create_js_minify_script.rb",
  "-p", "#{path}")
end

# Function: createMinifyScriptForCssFiles
# Description: The ruby script creates a js minify script for CleanCSS.
# Parameters:
#   - path: The path to the CSS files
# Returns: None
def createMinifyScriptForCssFiles(path)
  system("ruby",
  "#{BUILD_SOLUTION_PATH}/create_css_minify_script.rb",
  "-p", "#{path}")
end

# Function: includeMinifyFilesIntoHtmlFiles
# Description: Includes minified files into HTML files.
# Parameters:
#   - path: The path to the HTML files
# Returns: None
def includeMinifyFilesIntoHtmlFiles(path)

  puts "*" * 50
  puts "Embed Minified files in HTML files started\n\n"

  Dir[path+'/**/*.html'].each do |html_file|
    if false == html_file.include?(".min.html")
      puts " => Unminified html file found: ..#{html_file.gsub(path, "")}"
      html_content = File.read(html_file)
      removeCommentsFromHtmlFile(html_content)
      
      puts "  => Include minimized JS and CSS files in HTML file."
      # include minify files into html files
      includeMinifyJsFiles(WEBSITE_JS_PATH, html_content)
      includeMinifyJsFiles(WEBSITE_VUE_PATH, html_content)
      includeMinifyCssFiles(WEBSITE_CSS_PATH, html_content)
      includeMinifyCssFiles(WEBSITE_VUE_PATH, html_content)

      File.write "#{path}/#{File.basename(html_file, ".html")}.min.html", html_content
    end
  end

  puts "*" * 50
  puts "Embed Minified files in HTML files finished"
  puts "*" * 50
  puts ""

end

# Function: includeMinifyCssFiles
# Description: Includes minified CSS files into HTML content.
# Parameters:
#   - path: The path to the CSS files
#   - html_content: The content of the HTML file
# Returns: None
def includeMinifyCssFiles(path, html_content)
  # Replace .css filenames by .min.css filenames
  Dir[path + '/**/*.css'].each do |css_file|
    if false == css_file.include?(".min.css")
      puts "    - Replaced file #{File.basename(css_file)} with file #{File.basename(css_file, ".css") + ".min.css"}"
      html_content.gsub! File.basename(css_file), (File.basename(css_file, ".css") + ".min.css")
    end
  end
end

# Function: includeMinifyJsFiles
# Description: Includes minified JavaScript files into HTML content.
# Parameters:
#   - path: The path to the JavaScript files
#   - html_content: The content of the HTML file
# Returns: None
def includeMinifyJsFiles(path, html_content)
  # Replace .js filenames by .min.js filenames
  Dir[path + '/**/*.js'].each do |js_file|
    if false == js_file.include?(".min.js")
      puts "    - Replaced file #{File.basename(js_file)} with file #{File.basename(js_file, ".js") + ".min.js"}"
      html_content.gsub! File.basename(js_file), (File.basename(js_file, ".js") + ".min.js")
    end
  end
end
