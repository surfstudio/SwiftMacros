# Class to contain all needed information about a module
class Specs
  attr_accessor :dir, :name, :content_func, :allowed_to_rewrite

  def initialize(dir, name, content_func, allowed_to_rewrite = false)
    @dir = dir
    @name = name
    @content_func = content_func
    @allowed_to_rewrite = allowed_to_rewrite
  end

end

# Create list of specs for every module
def create_modules_specs(macro_name, macro_type, macro_group)
  implementation_dir = "Implementation"
  [
    # Macros
    Specs.new(
      "Macros",
      "#{macro_name}.swift",
      lambda { template("macros", { 'macro_name' => macro_name, 'macro_type' => macro_type }) }
    ),

    # Implementation
    Specs.new(
      implementation_dir, 
      "#{macro_type}.swift",
      lambda { template("implementation", { 'macro_type' => macro_type }) }
    ),

    # Plugin
    Specs.new(
      implementation_dir,
      "#{macro_group}Plugin.swift",
      lambda { 
        template(
          "plugin_group",
          { 
            'macro_group' => macro_group,
            'macro_types' => all_macro_types_in_dir("#{implementation_dir}/#{macro_group}")
          }
        ) 
      },
      true
    ),

    # Test
    Specs.new(
      "../../Tests/SurfMacros",
      "#{macro_name}Tests.swift",
      lambda { template("test", { 'macro_name' => macro_name, 'macro_type' => macro_type }) }
    )
  ]
end
