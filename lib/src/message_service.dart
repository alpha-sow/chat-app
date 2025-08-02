import 'dart:async';

import 'package:chat_app_package/src/src.dart';
import 'package:uuid/uuid.dart';

class MessageService {
  MessageService._();
  static MessageService? _instance;

  static MessageService get instance {
    _instance ??= MessageService._();
    return _instance!;
  }

  LocalDatabaseService get _database => LocalDatabaseService.instance;
  SyncService get _syncService => SyncService.instance;

  Stream<List<Message>> watchMessagesForDiscussion(String discussionId) {
    return _database.watchMessagesForDiscussion(
      discussionId,
    );
  }

  void sendMessage({
    required String discussionId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
  }) {
    final message = Message(
      id: const Uuid().v4(),
      senderId: senderId,
      content: content,
      type: type,
      replyToId: replyToId,
      timestamp: DateTime.now(),
    );

    _database.saveMessage(message, discussionId);
    unawaited(_syncService.syncMessages());
  }

  void deleteMessage(String messageId) {
    _database.deleteMessage(messageId);
    unawaited(_syncService.syncMessages());
  }
}
