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
  transformed_list_selected_entries(
    dir,
    lambda { |entry| 
      entry.match?("^[a-zA-Z]+Macro\.swift$")
    }, lambda { |entry|
      entry.sub("swift", "self") 
    }
  )
end

# Return all macros plugins of the groups of the dir as a string
def all_macros_plugins_in_dir(dir)
  transformed_list_selected_entries(
    dir,
    lambda { |entry|
      entry.match?("^[a-zA-Z]+$") && is_macro_group_dir(entry)
    }, lambda { |entry|
      entry.concat("Plugin.providingMacros")
    }
  ) 
end

# String of entries that match regex in the directory
def transformed_list_selected_entries(dir, selector, transformation)
  indent = ' ' * 8
  Dir.entries(dir)
    .select(&selector)
    .map(&transformation) 
    .join(",\n#{indent}")
end

# Determines whether the directory contains the file
def is_macro_group_dir(dir)
  plugin_file_path = File.join("Implementation/#{dir}", "#{dir}Plugin.swift")
  File.exist?(plugin_file_path)
end
