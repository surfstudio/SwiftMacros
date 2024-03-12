require 'liquid'
require 'fileutils'

# Function to convert name.liquid template with input data into string 
def template(name, data)
  template_string = File.read("support/macro_generator/templates/#{name}.liquid")
  template = Liquid::Template.parse(template_string)
  template.render(data)
end

# Extract input arguments
if ARGV.length < 1
  puts "Error: no arguments specified."
  exit
end
macro_name = (ARGV[0]).capitalize
macro_group = (ARGV.length > 1 ? ARGV[1] : ARGV[0]).capitalize
macro_type = "#{macro_name.capitalize}Macro"

# Configure specs for every module
macros_dir = "Sources/SurfMacros/Macros"
macros_name = "#{macro_name}.swift"
macros_content = ""

implementation_dir = "Sources/SurfMacros/Implementation"
implementation_name = "#{macro_type}.swift"
implementation_content = ""

plugin_dir = implementation_dir
plugin_name = "#{macro_group}Plugin.swift"
plugin_content = template("plugin", { 'macro_group' => macro_group })

tests_dir = "Tests/SurfMacros"
test_name = "#{macro_name}Tests.swift"
test_content = template("test", { 'macro_name' => macro_name.downcase, 'macro_type' => macro_type })

specs = [
  [macros_dir, macros_name, macros_content],
  [implementation_dir, implementation_name, implementation_content],
  [plugin_dir, plugin_name, plugin_content],
  [tests_dir, test_name, test_content]
]

# Create files and dirs
specs.each do |dir, name, content|
  group_dir = "#{dir}/#{macro_group}"
  file_path = "#{group_dir}/#{name}"

  # If a file for the macro exists
  # Skip it without rewriting
  unless File.exist?(file_path)
    FileUtils.mkdir_p(group_dir)
    File.write(file_path, content)
    puts "Created: #{file_path}"
  else
    puts "Already exists: #{file_path}"
  end
end
