# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dart package project called `chat_app_package` - a starting point for Dart libraries or applications. The project uses standard Dart package structure and is currently in early development with placeholder implementations.

## Development Commands

### Core Commands

- `dart pub get` - Install dependencies
- `dart test` - Run all tests  
- `dart test test/chat_app_test.dart` - Run specific test file
- `dart analyze` - Run static analysis
- `dart run example/chat_app_example.dart` - Run the example

### Code Generation

- `dart run build_runner build` - Generate code (freezed models)
- `dart run build_runner build --delete-conflicting-outputs` - Clean rebuild
- `dart run build_runner watch` - Watch for changes and rebuild

### Linting

- Uses `package:very_good_analysis` for static analysis (stricter rules than standard lints)
- Configuration in `analysis_options.yaml`

## Architecture

### Package Structure

- `lib/chat_app_package.dart` - Main library export file
- `lib/src/chat_app_base.dart` - Core implementation classes
- `lib/src/models/` - Data models (currently empty, intended for freezed models)
- `test/` - Unit tests using the `test` package
- `example/` - Usage examples

### Dependencies

- **freezed_annotation** (^3.1.0) - For immutable data classes
- **build_runner** (^2.6.0) - Code generation
- **freezed** (^3.2.0) - Immutable data class generation
- **test** (^1.24.0) - Testing framework
- **very_good_analysis** (^7.0.1) - Strict Dart linting rules

### Key Patterns

- Uses freezed for immutable data models (setup but not implemented yet)
- Standard Dart package export pattern through main library file
- Test-driven development setup with dedicated test files
