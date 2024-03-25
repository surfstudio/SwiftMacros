## VSURF-Support

## Команда для инициализации проекта, выполняйте всегда перед первым стартом!
init:
	# Установить bundler, если еще не установлен
	if ! gem spec bundler > /dev/null 2>&1; then\
  	echo "bundler gem is not installed!";\
  	sudo gem install bundler -v "2.1.4";\
	fi
	bundle update
	bundle config set --local path '.bundle'
	bundle install




## Генерирует файлы для макроса с указанным именем. Параметры: name=<macroName> [group=<macroGroup>]
macro:
	@bundle exec ruby support/macro_generator/generator.rb $(name) $(group)




# Цвета
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

TARGET_MAX_CHAR_NUM=20
## Показывает все возможные команды в данном MakeFile-е
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
