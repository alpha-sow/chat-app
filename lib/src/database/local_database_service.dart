import 'dart:async';

import 'package:chat_app_package/chat_app_package.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local database service using Hive for data persistence.
///
/// This service provides CRUD operations for discussions, messages, and users
/// using the Hive database. It handles data conversion between domain models
/// and Hive models, and provides both synchronous and asynchronous operations.
class LocalDatabaseService {
  LocalDatabaseService._();
  static LocalDatabaseService? _instance;
  static Box<HiveMessage>? _messagesBox;
  static Box<HiveDiscussion>? _discussionsBox;
  static Box<HiveUser>? _usersBox;

  /// Gets the singleton instance of the database service.
  static LocalDatabaseService get instance {
    _instance ??= LocalDatabaseService._();
    return _instance!;
  }

  /// Initializes the Hive database with required adapters and boxes.
  ///
  /// Must be called before using the database service. Sets up the
  /// database with adapters for messages, discussions, and users.
  ///
  /// [directory] The directory path where the database files will be stored.
  /// For web, this parameter is ignored as IndexedDB is used instead.
  static Future<void> initialize({required String directory}) async {
    if (_messagesBox != null) return;

    if (kIsWeb) {
      // For web, just initialize Hive without directory
      await Hive.initFlutter();
    } else {
      // For mobile/desktop, use the provided directory
      await Hive.initFlutter(directory);
    }

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveMessageAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HiveDiscussionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HiveUserAdapter());
    }

    // Open boxes
    _messagesBox = await Hive.openBox<HiveMessage>('messages');
    _discussionsBox = await Hive.openBox<HiveDiscussion>('discussions');
    _usersBox = await Hive.openBox<HiveUser>('users');
  }

  /// Gets the initialized Hive message box.
  ///
  /// Throws [StateError] if the database hasn't been initialized.
  Box<HiveMessage> get messagesBox {
    if (_messagesBox == null) {
      throw StateError(
        'Database not initialized. Call DatabaseService.initialize() first.',
      );
    }
    return _messagesBox!;
  }

  /// Gets the initialized Hive discussion box.
  ///
  /// Throws [StateError] if the database hasn't been initialized.
  Box<HiveDiscussion> get discussionsBox {
    if (_discussionsBox == null) {
      throw StateError(
        'Database not initialized. Call DatabaseService.initialize() first.',
      );
    }
    return _discussionsBox!;
  }

  /// Gets the initialized Hive user box.
  ///
  /// Throws [StateError] if the database hasn't been initialized.
  Box<HiveUser> get usersBox {
    if (_usersBox == null) {
      throw StateError(
        'Database not initialized. Call DatabaseService.initialize() first.',
      );
    }
    return _usersBox!;
  }

  /// Saves a discussion to the local database.
  ///
  /// Converts the Discussion domain model to HiveDiscussion and stores it.
  /// Uses the discussion ID as the key for efficient lookups.
  /// [discussion] The discussion object to save.
  Future<void> saveDiscussion(Discussion discussion) async {
    final hiveDiscussion = HiveDiscussion.fromDiscussion(discussion);
    await discussionsBox.put(discussion.id, hiveDiscussion);
  }

  /// Retrieves a discussion by ID from the local database.
  ///
  /// [discussionId] The ID of the discussion to retrieve.
  ///
  /// Returns the Discussion object if found, null otherwise.
  Future<Discussion?> getDiscussion(String discussionId) async {
    final hiveDiscussion = discussionsBox.get(discussionId);
    return hiveDiscussion?.toDiscussion();
  }

  /// Get All Discussions
  /// Gets all discussions from the local database.
  ///
  /// Returns a list of all Discussion objects.
  Future<List<Discussion>> getAllDiscussions() async {
    final hiveDiscussions = discussionsBox.values.toList();
    return hiveDiscussions.map((hd) => hd.toDiscussion()).toList();
  }

  /// Deletes a discussion and all its messages from the database.
  ///
  /// [discussionId] The ID of the discussion to delete.
  Future<void> deleteDiscussion(String discussionId) async {
    // Delete all messages in this discussion
    final messageKeys = messagesBox.keys
        .where((key) => messagesBox.get(key)?.discussionId == discussionId)
        .toList();

    await messagesBox.deleteAll(messageKeys);

    // Delete the discussion
    await discussionsBox.delete(discussionId);
  }

  /// Saves a message to the local database.
  ///
  /// [message] The message object to save.
  /// [discussionId] The ID of the discussion this message belongs to.
  Future<void> saveMessage(Message message, String discussionId) async {
    final hiveMessage = HiveMessage.fromMessage(message, discussionId);
    await messagesBox.put(message.id, hiveMessage);
  }

  /// Gets messages for a specific discussion with pagination.
  ///
  /// [discussionId] The ID of the discussion.
  ///
  /// Returns a list of Message objects for the discussion.
  Future<List<Message>> getMessagesForDiscussion(String discussionId) async {
    final allMessages =
        messagesBox.values
            .where((hm) => hm.discussionId == discussionId)
            .toList()
          // Sort by timestamp
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return allMessages.map((hm) => hm.toMessage()).toList();
  }

  /// Retrieves a specific message by its ID.
  ///
  /// [messageId] The ID of the message to retrieve.
  ///
  /// Returns the Message object if found, null otherwise.
  Future<Message?> getMessage(String messageId) async {
    final hiveMessage = messagesBox.get(messageId);
    return hiveMessage?.toMessage();
  }

  /// Updates an existing message in the local database.
  ///
  /// [message] The updated message object.
  /// [discussionId] The ID of the discussion this message belongs to.
  Future<void> updateMessage(Message message, String discussionId) async {
    if (messagesBox.containsKey(message.id)) {
      final updatedMessage = HiveMessage.fromMessage(message, discussionId);
      await messagesBox.put(message.id, updatedMessage);
    }
  }

  /// Deletes a message from the local database.
  ///
  /// [messageId] The ID of the message to delete.
  Future<void> deleteMessage(String messageId) async {
    await messagesBox.delete(messageId);
  }

  /// Saves a user to the local database.
  ///
  /// [user] The user object to save.
  Future<void> saveUser(User user) async {
    final hiveUser = HiveUser.fromUser(user);
    await usersBox.put(user.id, hiveUser);
  }

  /// Retrieves a user by ID from the local database.
  ///
  /// [userId] The ID of the user to retrieve.
  ///
  /// Returns the User object if found, null otherwise.
  Future<User?> getUser(String userId) async {
    final hiveUser = usersBox.get(userId);
    return hiveUser?.toUser();
  }

  /// Gets all users from the local database.
  ///
  /// Returns a list of all User objects stored locally.
  Future<List<User>> getAllUsers() async {
    final hiveUsers = usersBox.values.toList();
    return hiveUsers.map((hu) => hu.toUser()).toList();
  }

  /// Deletes a user from the local database.
  ///
  /// [userId] The ID of the user to delete.
  Future<void> deleteUser(String userId) async {
    await usersBox.delete(userId);
  }

  /// Watches all discussions for real-time updates.
  ///
  /// Returns a stream that emits the current list of discussions
  /// whenever they change in the database.
  Stream<List<Discussion>> watchAllDiscussions() async* {
    // Emit initial value
    yield await getAllDiscussions();
    
    // Then watch for changes
    await for (final _ in discussionsBox.watch()) {
      yield await getAllDiscussions();
    }
  }

  /// Watches all users for real-time updates.
  ///
  /// Returns a stream that emits the current list of users
  /// whenever they change in the database.
  Stream<List<User>> watchAllUsers() async* {
    // Emit initial value
    yield await getAllUsers();
    
    // Then watch for changes
    await for (final _ in usersBox.watch()) {
      yield await getAllUsers();
    }
  }

  /// Watches messages for a specific discussion in real-time.
  /// Returns a stream that emits the current list of messages
  /// for the discussion whenever they change in the database.
  Stream<List<Message>> watchMessagesForDiscussion(String discussionId) async* {
    // Emit initial value
    yield await getMessagesForDiscussion(discussionId);
    
    // Then watch for changes
    await for (final _ in messagesBox.watch()) {
      yield await getMessagesForDiscussion(discussionId);
    }
  }

  Future<void> updateDiscussionById({
    required String id,
    required Message lastMessage,
    required DateTime lastActivity,
  }) async {
    final discussion = await getDiscussion(id);

    if (discussion != null) {
      final updatedDiscussion = discussion.copyWith(
        lastMessage: lastMessage,
        lastActivity: lastActivity,
      );

      await saveDiscussion(updatedDiscussion);
    }
  }
}
