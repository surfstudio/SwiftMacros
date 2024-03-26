## VSURF-Support

## Initialization
##
## Блок команд, которые необходимо запускать при старте работы с проектом
##

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


macro: ## Генерирует файлы для макроса с указанным именем. Параметры: name=<macroName> [group=<macroGroup>]
	@bundle exec ruby support/macro_generator/generator.rb $(name) $(group)




AWK := awk
help: ## Показывает все возможные команды в данном MakeFile-е
	@printf "\nUsage: make <command>\n\n"
	@grep -F -h "##" $(MAKEFILE_LIST) | grep -F -v grep -F | sed -e 's/\\$$//' | $(AWK) 'BEGIN {FS = ":*[[:space:]]*##[[:space:]]*"}; \
	{ \
		if($$2 == "") \
			printf "\n"; \
		else if($$0 ~ /^#/) \
			printf "\033[36m%s", $$2; \
		else if($$1 == "") \
			printf "     %-20s%s\n", "", $$2; \
		else \
			printf "    \033[32m%-20s\033[0m %s\n", $$1, $$2; \
	}'


# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
