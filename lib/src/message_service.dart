import 'dart:async';

import 'package:chat_app_package/src/src.dart';
import 'package:isar/isar.dart';

/// Service class for watching messages from the local database only.
///
/// This service provides real-time streaming capabilities for messages
/// without any remote synchronization. It focuses purely on local database
/// operations and watching for changes.
class MessageService {
  MessageService._();
  static MessageService? _instance;

  /// Gets the singleton instance of the message service.
  static MessageService get instance {
    _instance ??= MessageService._();
    return _instance!;
  }

  /// Gets the local database service instance.
  LocalDatabaseService get _database => LocalDatabaseService.instance;

  /// Watches messages for a specific discussion in real-time.
  ///
  /// Returns a stream that emits the current list of messages
  /// whenever they change in the local database for the given discussion.
  ///
  /// [discussionId] The ID of the discussion to watch messages for.
  /// [limit] Maximum number of messages to return (default: 100).
  /// [offset] Number of messages to skip (default: 0).
  ///
  /// The stream will emit immediately with current data and then
  /// emit again whenever messages are added, updated, or deleted.
  Stream<List<Message>> watchMessagesForDiscussion(
    String discussionId, {
    int limit = 100,
    int offset = 0,
  }) {
    return _database.isar.isarMessages
        .where()
        .discussionIdEqualTo(discussionId)
        .sortByTimestamp()
        .watch(fireImmediately: true)
        .map((List<IsarMessage> isarMessages) {
          return isarMessages.map((IsarMessage im) => im.toMessage()).toList();
        });
  }
}
