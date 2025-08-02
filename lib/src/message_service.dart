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

  Future<void> sendMessage({
    required String discussionId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
  }) async {
    final message = Message(
      id: const Uuid().v4(),
      senderId: senderId,
      content: content,
      type: type,
      replyToId: replyToId,
      timestamp: DateTime.now(),
    );
    await Future.wait([
      _syncService.saveMessage(message, discussionId),
      _syncService.updateDiscussionById(
        id: discussionId,
        lastMessage: message,
        lastActivity: message.timestamp,
      ),
    ]);
  }

  Future<void> deleteMessage(String messageId, String discussionId) async {
    await _syncService.deleteMessage(messageId, discussionId);
  }

  Future<Message?> getMessage(String replyToMessageId) async {
    return _database.getMessage(replyToMessageId);
  }
}
