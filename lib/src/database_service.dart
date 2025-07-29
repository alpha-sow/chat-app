import 'dart:async';

import 'package:chat_app_package/src/src.dart';
import 'package:isar/isar.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  static Future<void> initialize({required String directory}) async {
    if (_isar != null) return;

    _isar = await Isar.open(
      [
        IsarMessageSchema,
        IsarDiscussionSchema,
        IsarUserSchema,
      ],
      directory: directory,
    );
  }

  Isar get isar {
    if (_isar == null) {
      throw StateError(
        'Database not initialized. Call DatabaseService.initialize() first.',
      );
    }
    return _isar!;
  }

  // Discussion operations
  Future<void> saveDiscussion(Discussion Discussion) async {
    final isarDiscussion = IsarDiscussion.fromDiscussion(Discussion);

    await isar.writeTxn(() async {
      await isar.isarDiscussions.put(isarDiscussion);
    });
  }

  Future<Discussion?> getDiscussion(String discussionId) async {
    final isarDiscussion = await isar.isarDiscussions
        .filter()
        .discussionIdEqualTo(discussionId)
        .findFirst();

    if (isarDiscussion == null) return null;

    // Load messages for this discussion
    final messages = await getMessagesForDiscussion(discussionId);
    final Discussion = isarDiscussion.toDiscussion();

    return Discussion.copyWith(messages: messages);
  }

  /// Get All Discussions
  Future<List<Discussion>> getAllDiscussions() async {
    final isarDiscussions = await isar.isarDiscussions.where().findAll();
    final discussions = <Discussion>[];

    for (final isarDiscussion in isarDiscussions) {
      final messages = await getMessagesForDiscussion(
        isarDiscussion.discussionId!,
      );
      final Discussion = isarDiscussion.toDiscussion();
      discussions.add(Discussion.copyWith(messages: messages));
    }

    return discussions;
  }

  Future<void> deleteDiscussion(String discussionId) async {
    await isar.writeTxn(() async {
      // Delete all messages in this discussion
      await isar.isarMessages
          .filter()
          .discussionIdEqualTo(discussionId)
          .deleteAll();

      // Delete the discussion
      await isar.isarDiscussions
          .filter()
          .discussionIdEqualTo(discussionId)
          .deleteAll();
    });
  }

  // Message operations
  Future<void> saveMessage(Message message, String discussionId) async {
    final isarMessage = IsarMessage.fromMessage(message, discussionId);

    await isar.writeTxn(() async {
      await isar.isarMessages.put(isarMessage);
    });
  }

  Future<List<Message>> getMessagesForDiscussion(
    String discussionId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final isarMessages = await isar.isarMessages
        .filter()
        .discussionIdEqualTo(discussionId)
        .sortByTimestamp()
        .offset(offset)
        .limit(limit)
        .findAll();

    return isarMessages.map((im) => im.toMessage()).toList();
  }

  Future<Message?> getMessage(String messageId) async {
    final isarMessage = await isar.isarMessages
        .filter()
        .messageIdEqualTo(messageId)
        .findFirst();

    return isarMessage?.toMessage();
  }

  Future<void> updateMessage(Message message, String discussionId) async {
    final existingMessage = await isar.isarMessages
        .filter()
        .messageIdEqualTo(message.id)
        .findFirst();

    if (existingMessage != null) {
      final updatedMessage = IsarMessage.fromMessage(message, discussionId);
      updatedMessage.id = existingMessage.id; // Keep the same Isar ID

      await isar.writeTxn(() async {
        await isar.isarMessages.put(updatedMessage);
      });
    }
  }

  Future<void> deleteMessage(String messageId) async {
    await isar.writeTxn(() async {
      await isar.isarMessages.filter().messageIdEqualTo(messageId).deleteAll();
    });
  }

  // User operations
  Future<void> saveUser(User user) async {
    final isarUser = IsarUser.fromUser(user);

    await isar.writeTxn(() async {
      await isar.isarUsers.put(isarUser);
    });
  }

  Future<User?> getUser(String userId) async {
    final isarUser = await isar.isarUsers
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    return isarUser?.toUser();
  }

  Future<List<User>> getAllUsers() async {
    final isarUsers = await isar.isarUsers.where().findAll();
    return isarUsers.map((iu) => iu.toUser()).toList();
  }

  Future<void> deleteUser(String userId) async {
    await isar.writeTxn(() async {
      await isar.isarUsers.filter().userIdEqualTo(userId).deleteAll();
    });
  }

  // Utility operations
  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _instance = null;
  }

  // Stream operations for real-time updates
  Stream<List<Message>> watchMessagesForDiscussion(String discussionId) {
    return isar.isarMessages
        .filter()
        .discussionIdEqualTo(discussionId)
        .watch(fireImmediately: true)
        .map(
          (isarMessages) => isarMessages.map((im) => im.toMessage()).toList(),
        );
  }

  Stream<List<Discussion>> watchAllDiscussions() {
    return isar.isarDiscussions.where().watch(fireImmediately: true).asyncMap((
      isarDiscussions,
    ) async {
      final discussions = <Discussion>[];
      for (final isarDiscussion in isarDiscussions) {
        final messages = await getMessagesForDiscussion(
          isarDiscussion.discussionId!,
        );
        final Discussion = isarDiscussion.toDiscussion();
        discussions.add(Discussion.copyWith(messages: messages));
      }
      return discussions;
    });
  }
}
