import 'dart:async';

import 'package:chat_app_package/src/src.dart';
import 'package:isar/isar.dart';

/// Local database service using Isar for data persistence.
/// 
/// This service provides CRUD operations for discussions, messages, and users
/// using the Isar database. It handles data conversion between domain models
/// and Isar models, and provides both synchronous and asynchronous operations.
class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;

  DatabaseService._();

  /// Gets the singleton instance of the database service.
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Initializes the Isar database with required schemas.
  /// 
  /// Must be called before using the database service. Sets up the
  /// database with schemas for messages, discussions, and users.
  /// 
  /// [directory] The directory path where the database files will be stored.
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

  /// Gets the initialized Isar database instance.
  /// 
  /// Throws [StateError] if the database hasn't been initialized.
  Isar get isar {
    if (_isar == null) {
      throw StateError(
        'Database not initialized. Call DatabaseService.initialize() first.',
      );
    }
    return _isar!;
  }

  /// Saves a discussion to the local database.
  /// 
  /// Converts the Discussion domain model to IsarDiscussion and stores it.
  /// [discussion] The discussion object to save.
  Future<void> saveDiscussion(Discussion discussion) async {
    final isarDiscussion = IsarDiscussion.fromDiscussion(discussion);

    await isar.writeTxn(() async {
      await isar.isarDiscussions.put(isarDiscussion);
    });
  }

  /// Retrieves a discussion by ID from the local database.
  /// 
  /// Loads the discussion with all its messages.
  /// [discussionId] The ID of the discussion to retrieve.
  /// 
  /// Returns the Discussion object if found, null otherwise.
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
  /// Gets all discussions from the local database.
  /// 
  /// Returns a list of all Discussion objects, each loaded with
  /// their associated messages.
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

  /// Deletes a discussion and all its messages from the database.
  /// 
  /// [discussionId] The ID of the discussion to delete.
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

  /// Saves a message to the local database.
  /// 
  /// [message] The message object to save.
  /// [discussionId] The ID of the discussion this message belongs to.
  Future<void> saveMessage(Message message, String discussionId) async {
    final isarMessage = IsarMessage.fromMessage(message, discussionId);

    await isar.writeTxn(() async {
      await isar.isarMessages.put(isarMessage);
    });
  }

  /// Gets messages for a specific discussion with pagination.
  /// 
  /// [discussionId] The ID of the discussion.
  /// [limit] Maximum number of messages to return (default: 100).
  /// [offset] Number of messages to skip (default: 0).
  /// 
  /// Returns a list of Message objects for the discussion.
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

  /// Retrieves a specific message by its ID.
  /// 
  /// [messageId] The ID of the message to retrieve.
  /// 
  /// Returns the Message object if found, null otherwise.
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

  /// Deletes a message from the local database.
  /// 
  /// [messageId] The ID of the message to delete.
  Future<void> deleteMessage(String messageId) async {
    await isar.writeTxn(() async {
      await isar.isarMessages.filter().messageIdEqualTo(messageId).deleteAll();
    });
  }

  /// Saves a user to the local database.
  /// 
  /// [user] The user object to save.
  Future<void> saveUser(User user) async {
    final isarUser = IsarUser.fromUser(user);

    await isar.writeTxn(() async {
      await isar.isarUsers.put(isarUser);
    });
  }

  /// Retrieves a user by ID from the local database.
  /// 
  /// [userId] The ID of the user to retrieve.
  /// 
  /// Returns the User object if found, null otherwise.
  Future<User?> getUser(String userId) async {
    final isarUser = await isar.isarUsers
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    return isarUser?.toUser();
  }

  /// Gets all users from the local database.
  /// 
  /// Returns a list of all User objects stored locally.
  Future<List<User>> getAllUsers() async {
    final isarUsers = await isar.isarUsers.where().findAll();
    return isarUsers.map((iu) => iu.toUser()).toList();
  }

  /// Deletes a user from the local database.
  /// 
  /// [userId] The ID of the user to delete.
  Future<void> deleteUser(String userId) async {
    await isar.writeTxn(() async {
      await isar.isarUsers.filter().userIdEqualTo(userId).deleteAll();
    });
  }

  /// Clears all data from the database.
  /// 
  /// This removes all discussions, messages, and users. Use with caution.
  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  /// Closes the database connection and cleans up resources.
  /// 
  /// This should be called when the app is shutting down.
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _instance = null;
  }

  /// Watches messages for a specific discussion in real-time.
  /// 
  /// [discussionId] The ID of the discussion to watch.
  /// 
  /// Returns a stream that emits updated message lists when they change.
  Stream<List<Message>> watchMessagesForDiscussion(String discussionId) {
    return isar.isarMessages
        .filter()
        .discussionIdEqualTo(discussionId)
        .watch(fireImmediately: true)
        .map(
          (isarMessages) => isarMessages.map((im) => im.toMessage()).toList(),
        );
  }

  /// Watches all discussions for real-time updates.
  /// 
  /// Returns a stream that emits the current list of discussions
  /// whenever they change in the database.
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
