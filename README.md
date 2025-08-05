# Chat App Package

A comprehensive Flutter chat application package with real-time messaging capabilities, built with Firebase Realtime Database and local storage using Isar.

## Features

- 🔥 **Real-time messaging** with Firebase Realtime Database
- 💾 **Offline storage** using Isar database
- 🔄 **Sync functionality** between local and remote databases
- 💬 **Reply system** with context preview
- 👥 **Group discussions** and direct messaging
- 📱 **Cross-platform** support (iOS, Android, Web, Desktop)
- 🎨 **Material Design** UI components
- 🔍 **Message selection** and bulk operations
- 👤 **User management** with avatars and profiles

## Architecture

This project follows a modular architecture with:

- **Package Structure**: Core chat functionality as a reusable Dart package
- **Example App**: Complete Flutter application demonstrating package usage
- **Data Models**: Immutable data classes using Freezed
- **Services**: Database, sync, and Firebase integration services
- **UI Components**: Reusable widgets for chat interface

## Getting Started

### Prerequisites

- Flutter 3.24.0 or higher
- Dart 3.8.1 or higher
- Firebase project setup for real-time database

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd chat_app
   ```

1. Install dependencies for the package:

   ```bash
   dart pub get
   ```

1. Install dependencies for the example app:

   ```bash
   cd example/chat_flutter_app
   flutter pub get
   ```

1. Generate code for data models:

   ```bash
   dart run build_runner build
   ```

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Realtime Database
3. Add your platform-specific configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `web/firebase-config.js` (if using web)

## Usage

### Basic Implementation

```dart
import 'package:dayder_chat/dayder_chat.dart';

// Initialize the database service
await DatabaseService.instance.initialize();

// Create a discussion
final discussion = await DiscussionService.create(
  title: 'My Chat',
  participants: ['user1', 'user2'],
);

// Send a message
discussion.addMessage('user1', 'Hello, world!');

// Listen to messages
discussion.messages.listen((messages) {
  // Update UI with new messages
});
```

### Complete Example

Check the `example/chat_flutter_app` directory for a complete Flutter application demonstrating:

- User authentication
- Discussion creation and management
- Real-time messaging
- Reply functionality
- Message deletion
- User interface components

## Development Commands

### Core Commands

- `dart pub get` - Install dependencies
- `dart test` - Run all tests  
- `dart analyze` - Run static analysis
- `dart run example/chat_app_example.dart` - Run the example

### Code Generation

- `dart run build_runner build` - Generate code (freezed models)
- `dart run build_runner build --delete-conflicting-outputs` - Clean rebuild
- `dart run build_runner watch` - Watch for changes and rebuild

### Example App Commands

```bash
cd example/chat_flutter_app
flutter run                    # Run on connected device
flutter build apk             # Build Android APK
flutter build ios             # Build iOS app
flutter test                  # Run tests
```

## Project Structure

```text
chat_app/
├── lib/                      # Package source code
│   ├── src/
│   │   ├── models/          # Data models (User, Message, Discussion)
│   │   ├── services/        # Core services
│   │   └── utils/           # Utility functions
│   └── chat_app_package.dart # Main package export
├── example/
│   └── chat_flutter_app/    # Example Flutter application
├── test/                    # Package tests
└── CLAUDE.md               # Development guidelines
```

## Dependencies

### Core Dependencies

- `firebase_database` - Real-time database
- `isar` - Local database
- `freezed_annotation` - Immutable data classes
- `logger` - Logging utility
- `uuid` - Unique identifier generation

### Development Dependencies

- `build_runner` - Code generation
- `freezed` - Data class generation
- `very_good_analysis` - Strict linting rules

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the coding standards
4. Run tests and linting (`dart test && dart analyze`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Code Quality

This project uses strict linting rules with `very_good_analysis`. All code must pass:

- Static analysis (`dart analyze`)
- Unit tests (`dart test`)
- Code formatting (`dart format`)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.
