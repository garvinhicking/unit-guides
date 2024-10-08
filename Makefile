## Global PHP arguments, applied to both docker and local execution
PHP_ARGS ?= -d memory_limit=1024M

## Docker wrapper, for raw php commands (so it's not required on the host)
## This container has no runtime for the `guides` project!
PHP_BIN ?= docker run -i --rm --user $$(id -u):$$(id -g) -v${PWD}:/opt/project -w /opt/project php:8.1-cli php $(PHP_ARGS)

## Docker wrapper to use for a phpunit:local container.
## This container provides a runtime for the `guides` project
PHP_PROJECT_BIN ?= docker run -i --rm --user $$(id -u):$$(id -g) -v${PWD}:/project phpunit:local

## Docker wrapper to use for a phpunit:local container.
## This container provides a composer-runtime; mounts project on /app
PHP_COMPOSER_BIN ?= docker run -i --rm --user $$(id -u):$$(id -g) -v${PWD}:/app composer:2

## These variables can be overriden by other tasks, i.e. by `make PHP_ARGS=-d memory_limit=2G pre-commit-tests`.
## The "--user" argument is required for macOS to pass along ownership of /project

## NOTE: Dependencies listed here (PHP 8.1, composer 2) need to be kept
##       in sync with those inside the Dockerfile and composer.json

## Parse the "make (target) ENV=(local|docker)" argument to set the environment. Defaults to docker.
ifdef ENV
	ifeq ($(ENV),local)
		PHP_BIN = php $(PHP_ARGS)
		PHP_PROJECT_BIN = php $(PHP_ARGS) ./vendor/bin/guides
		PHP_COMPOSER_BIN = composer
		ENV_INFO=ENVIRONMENT: Local (also DDEV)
	else
		ENV_INFO=ENVIRONMENT: Docker
	endif
else
	ENV_INFO=ENVIRONMENT: Docker (default)
endif

.PHONY: help
help: ## Displays this list of targets with descriptions
	@echo "You prepend/append the argument 'ENV=(local|docker)' to each target. This specifies,"
	@echo "whether to execute the target within your local environment, or docker (default).\n"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

## LIST: Targets that can be executed directly

.PHONE: assets
assets: ## Builds all assets (Css, JavaScript, Fonts etc).
	ddev npm-build

.PHONE: assets-install
assets-install: ## Installs the node-modules needed to build the assets.
	ddev npm-ci

.PHONE: assets-debug
assets-debug: ## Builds assets, keeping the sourcemap. It copies the output files directly into Documentation-GENERATED-temp so they can be tested without reloading.
	ddev npm-debug

.PHONY: cleanup
cleanup: cleanup-tests cleanup-cache

.PHONY: cleanup-cache
cleanup-cache: ## Cleans up phpstan .cache directory
	@sudo rm -rf .cache

.PHONY: cleanup-tests
cleanup-tests: ## Cleans up temp directories created by test-integration
	@find ./tests -type d -name 'temp' -exec sudo rm -rf {} \;

.PHONY: code-style
code-style: ## Executes php-cs-fixer with "check" option
	@echo "$(ENV_INFO)"
	$(PHP_BIN) vendor/bin/php-cs-fixer check

.PHONY: docs
docs: ## Generate projects docs (from "Documentation" directory)
	@echo "$(ENV_INFO)"
	$(PHP_BIN) vendor/bin/guides -vvv --no-progress --config=Documentation

.PHONY: docker-build
docker-build: ## Build docker image 'phpunit:local' for local debugging
	docker build -t phpunit:local .

.PHONY: fix-code-style
fix-code-style: ## Executes php-cs-fixer with "fix" option
	@echo "$(ENV_INFO)"
	$(PHP_BIN) vendor/bin/php-cs-fixer fix

.PHONY: phpstan
phpstan: ## Execute phpstan
	@echo "$(ENV_INFO)"
	$(PHP_BIN) vendor/bin/phpstan --configuration=phpstan.neon

.PHONY: phpstan-baseline
phpstan-baseline: ## Generates phpstan baseline
	@echo "$(ENV_INFO)"
	$(PHP_BIN) vendor/bin/phpstan --configuration=phpstan.neon --generate-baseline

.PHONY: show-env
show-env: ## Shows PHP environment options (buildinfo)
	@echo "$(ENV_INFO)"
	@echo "Base PHP:"
	$(PHP_BIN) --version
	@echo ""

	@echo "Project within Docker:"
	docker run --rm --user $$(id -u):$$(id -g) -v${PWD}:/project phpunit:local --version
	$(PHP_PROJECT_BIN) --version
	@echo ""

.PHONY: test
test: test-integration test-unit test-xml test-docs test-rendertest ## Runs all test suites with phpunit/phpunit

## LIST: Compound targets that are triggers for others.

.PHONY: cleanup
cleanup: cleanup-tests cleanup-cache ## Runs all cleanup tasks

.PHONY: static-code-analysis
static-code-analysis: vendor phpstan ## Runs a static code analysis with phpstan (ensures composer)

## LIST: Triggered targets that operate on specific file changes

vendor: composer.json composer.lock
	@echo "$(ENV_INFO)"
	$(PHP_COMPOSER_BIN) composer validate --no-check-publish
	$(PHP_COMPOSER_BIN) composer install --no-interaction --no-progress  --ignore-platform-reqs
