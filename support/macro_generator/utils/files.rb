# Create all the needed files and dirs with provided specs in a macro group
def create_files_and_dirs(specs, macro_group)
  group_dir = "#{specs.dir}/#{macro_group}"
  file_path = "#{group_dir}/#{specs.name}"

  file_exist = File.exist?(file_path)
  if !file_exist || specs.allowed_to_rewrite
    FileUtils.mkdir_p(group_dir)
    File.write(file_path, specs.content_func.call)
    puts file_exist ? "Rewritten: #{file_path}" : "Created: #{file_path}"
  else
    puts "Already exists: #{file_path}"
  end
end

# Return all macro types in the dir as a string
def all_macro_types_in_dir(dir)
  transformed_list_matching_entries(
    dir,
    "^[a-zA-Z]+Macro\.swift$",
    lambda { |entry| entry.sub("swift", "self") }
  )
end

# Returns all macros plugins of the groups of the dir as a string
def all_macros_plugins_in_dir(dir)
  transformed_list_matching_entries(
    dir,
    "^[a-zA-Z]+$",
    lambda { |entry| entry.concat("Plugin.providingMacros") }
  ) 
end

# String of entries that match regex in the directory
def transformed_list_matching_entries(dir, regex, transformation)
  indent = ' ' * 8
  list_matching_entries(dir, regex)
    .map { |entry| transformation.call(entry) }
    .join(",\n#{indent}")
end

# List of entries that match regex in the directory
def list_matching_entries(dir, regex)
  Dir.entries(dir).select { |entry| entry.match?(regex) }
end
