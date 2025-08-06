.PHONY: help pub-get install test analyze run-example build-gen build-gen-clean build-gen-watch clean lint all

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

get: ## Install dependencies
	PUB_HOSTED_URL=https://repo.alphasow.dev/artifactory/api/pub/repo-pub flutter pub get

test: ## Run all tests
	flutter test

test-specific: ## Run specific test file (usage: make test-specific FILE=test/chat_app_test.dart)
	flutter test $(FILE)

analyze: ## Run static analysis
	flutter analyze

build: ## Clean rebuild with conflicting outputs deletion
	flutter packages pub run build_runner build --delete-conflicting-outputs

build-gen-watch: ## Watch for changes and rebuild
	flutter packages pub run build_runner watch

clean: ## Clean Flutter project
	flutter clean
	$(MAKE) install

lint: analyze ## Alias for analyze

all: install analyze test build-gen build ## Install, analyze, test, and generate code, then build

dev: install analyze ## Quick development setup