require 'liquid'
require 'fileutils'

require_relative 'utils/specs'
require_relative 'utils/template'
require_relative 'utils/files'

# Extract input arguments
if ARGV.length < 1
  puts "Error: no arguments specified."
  exit
end
macro_name = (ARGV[0]).capitalize
macro_type = "#{macro_name}Macro"
macro_group = (ARGV.length > 1 ? ARGV[1] : ARGV[0]).capitalize

# Go to SurfMacros
Dir.chdir("Sources/SurfMacros")

# Create files and dirs
create_modules_specs(macro_name, macro_type, macro_group).each do |specs|
  create_files_and_dirs(specs, macro_group)
end

# Update MacrosPlugin.swift
implementation_dir = "Implementation"
plugin_main_dir = "#{implementation_dir}/MacrosPlugin.swift"
File.write(
  plugin_main_dir,
  template("plugin_main", { 'group_plugins' => all_macros_plugins_in_dir(implementation_dir) })
)
puts "Updated: #{plugin_main_dir}"
