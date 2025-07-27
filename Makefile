# Dart Project Makefile

.PHONY: help get build clean test analyze format

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

get: ## Install dependencies
	dart pub get

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