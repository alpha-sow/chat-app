# Dart Project Makefile

.PHONY: help get build clean test analyze format

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

get: ## Install dependencies
	PUB_HOSTED_URL=https://repo.alphasow.dev/artifactory/api/pub/repo-pub dart pub get

add: ## Add a package (usage: make add PACKAGE=package_name or make add package_name)
	@if [ -n "$(PACKAGE)" ]; then \
		PUB_HOSTED_URL=https://repo.alphasow.dev/artifactory/api/pub/repo-pub dart pub add $(PACKAGE); \
	elif [ -n "$(filter-out add,$(MAKECMDGOALS))" ]; then \
		PUB_HOSTED_URL=https://repo.alphasow.dev/artifactory/api/pub/repo-pub dart pub add $(filter-out add,$(MAKECMDGOALS)); \
	else \
		echo "Usage: make add PACKAGE=package_name or make add package_name"; \
		exit 1; \
	fi

%:
	@:

build: ## Generate code with build_runner
	dart run build_runner build --delete-conflicting-outputs

build-watch: ## Watch for changes and rebuild
	dart run build_runner watch --delete-conflicting-outputs

clean: ## Clean generated files
	dart run build_runner clean

test: ## Run tests
	dart test

analyze: ## Run static analysis
	dart analyze

format: ## Format code
	dart format .

all: get build test analyze ## Run get, build, test, and analyze