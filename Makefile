## VSURF-Support

init: ## Команда для инициализации проекта, выполняйте всегда перед первым стартом!
	$(MAKE) install.gems
	$(MAKE) install.brews
	$(MAKE) install.hooks

install.gems: ## Установит Bundler и гемы
	if ! gem spec bundler > /dev/null 2>&1; then\
		echo "bundler gem is not installed!";\
		sudo gem install bundler -v "2.4.13";\
	fi
	bundle config set path '.bundle'
	bundle install

install.brews: ## Установит утилиты
	brew bundle --no-upgrade

install.hooks: ## Установит хуки
	mkdir -p .git/hooks
	$(MAKE) install.hook name=pre-commit
	$(MAKE) install.hook name=prepare-commit-msg
	$(MAKE) install.hook name=commit-msg

install.hook: ## Установит конкретный хук
              ## Пример: `make install.hook name=pre-commit`
	chmod +x support/hooks/$(name)
	ln -s -f ../../support/hooks/$(name) .git/hooks/$(name)

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
