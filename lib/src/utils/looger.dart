import 'package:logger/logger.dart';

/// Centralized logger instance
final logger = Logger(
  printer: PrettyPrinter(
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
