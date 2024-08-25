#!/usr/bin/env ruby
require 'optparse'
require 'nokogiri'
require 'json'

# Function: parse_options
# Description: Parses command-line options using the OptionParser class.
# Parameters: None
# Returns: A hash containing the parsed options
def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{File.basename __FILE__} -p <path>"

    opts.on("-p", "--path PATH", "Path to the directory") do |path|
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


# Function: parse_vue_component_files
# Description: Parses language strings from Vue files. It reads the content of a Vue file, 
#              uses Nokogiri to parse the HTML, and extracts the content of the <i18n> element.
#              It raises an error if there is more than one <i18n> element in the file. 
#              It parses the country codes and language strings from the <i18n> content and merges
#              them into the language hash.
# Parameters:
#   - vue_file: The path to the Vue file to be parsed
#   - country_codes: An array to store the parsed country codes
#   - language: A hash to store the parsed language strings
# Returns: An array containing the updated country_codes and language hash
def parse_vue_component_files(vue_components_list, country_codes, language)

  puts "=> Parsing language strings from the Vue3 components."
  vue_components_list.each do |vue_file|
    puts " - Parse #{File.basename(vue_file)} for i18n language strings"

    # Read the content of the vue file
    vue_file_content = File.read(vue_file)
    html = Nokogiri::HTML(vue_file_content)

    # Find the <i18n> root element
    i18n = html.xpath("/html/body/i18n")
    raise "The vue-file '#{File.basename(vue_file)}' must contain no or one <i18n> root element." if i18n.length > 1
  
    i18n_content = '{}'
    if i18n.length == 1
      # Extract the content of the <i18n> element
      i18n_str = i18n.first.to_s.gsub(/\A\s*<i18n>(.*)<\/i18n>\s*\z/m,'\1').strip

      # Parse the country codes
      if language.nil?
        language = {}
        JSON.parse(i18n_str).keys.each do |lang|
          country_codes.push(lang) unless country_codes.include?(lang)
          language.merge!({ lang.to_s => {} })
        end
      end

      # Parse the language strings
      country_codes.each do |countrycode|
        keys =  JSON.parse(i18n_str)[countrycode].keys
        values = JSON.parse(i18n_str)[countrycode].values
        keys.each_with_index do |item, index|
          language[countrycode].merge!({ keys[index] => values[index] })
        end
      end
    end
  end
  [country_codes, language]
end

# Function: write_total_language_files
# Description: Writes the language files in one language file and in different formats.
# Parameters:
#   - options: A hash containing the parsed command-line options
#   - language: A hash containing the parsed language strings
#   - country_codes: An array of parsed country codes
# Returns: None
def write_total_language_files(options, language, country_codes)
  
  puts "=> Write total languages file"
  Dir.mkdir(options[:path].gsub('/vue', '/json')) unless File.exists?(options[:path].gsub('/vue', '/json'))

  json_path = options[:path].gsub('/vue', '/json') + '/languages.json'
  puts " - Write: #{json_path}"
  File.write(json_path, JSON.pretty_generate(language))

  js_language = "const GLOBAL_Language = #{JSON.pretty_generate(language)}"
  js_path = options[:path].gsub('/vue', '/js') + '/languages.js'
  puts " - Write: #{js_path}"
  File.write(js_path, js_language)
end

# Function: write_separate_language_files
# Description: Writes separate language files for each country code.
# Parameters:
#   - options: A hash containing the parsed command-line options
#   - language: A hash containing the parsed language strings
#   - country_codes: An array of parsed country codes
# Returns: None
def write_separate_language_files(options, language, country_codes)
  puts "=> Write separated language files"
  Dir.mkdir(options[:path].gsub('/vue', '/json')) unless File.exists?(options[:path].gsub('/vue', '/json'))

  country_codes.each do |countrycode|
    file_path = "#{options[:path].gsub('/vue', '/json')}/language_#{countrycode}.json"
    puts " - Write language files for #{countrycode}: #{file_path}"
    File.write(file_path, JSON.pretty_generate({ countrycode => language[countrycode] }))
  end
end

# Main script execution
options = parse_options

puts "*" * 50
puts "Vue i18n language export started\n\n"

vue_components_list = search_vue_components(options[:path])

country_codes = []
language = nil
country_codes, language = parse_vue_component_files(vue_components_list, country_codes, language)

write_total_language_files(options, language, country_codes)
write_separate_language_files(options, language, country_codes)

puts "*" * 50
puts "Vue i18n language export finished"
puts "*" * 50
puts ""
