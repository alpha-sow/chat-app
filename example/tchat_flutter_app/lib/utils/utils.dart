import 'package:faker/faker.dart';
import 'package:logger/logger.dart';

/// Centralized logger instance used throughout the application
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Centralized faker instance for generating realistic sample data
final faker = Faker();