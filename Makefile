## VSURF-Support

## Command to initialize the project, always execute before the first launch! 
init:
	# Install bundler if not installed
	if ! gem spec bundler > /dev/null 2>&1; then\
  	echo "bundler gem is not installed!";\
  	sudo gem install bundler -v "2.1.4";\
	fi
	bundle update
	bundle config set --local path '.bundle'
	bundle install




## Create files for a macro with the given name. Example: make macro name=<MacroName>
macro:
	ruby support/macro_generator/generator.rb $(name) $(group)
