# Convert name.liquid template with input data into string 
def template(name, data)
  template_string = File.read("../../support/macro_generator/templates/#{name}.liquid")
  template = Liquid::Template.parse(template_string)
  template.render(data)
end
