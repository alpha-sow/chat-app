import 'dart:async';

import 'package:chat_app_package/src/src.dart';

/// Stub implementation for web platform where Isar is not supported
class LocalDatabaseService {
  LocalDatabaseService._();
  static LocalDatabaseService? _instance;

  static LocalDatabaseService get instance {
    _instance ??= LocalDatabaseService._();
    return _instance!;
  }

  static Future<void> initialize({required String directory}) async {
    // No-op for web
  }

  // Discussion methods
  Future<void> saveDiscussion(Discussion discussion) async {
    throw UnsupportedError('Local database not supported on web platform');
  }

  Future<Discussion?> getDiscussion(String discussionId) async {
    return null;
  }

  Future<List<Discussion>> getAllDiscussions() async {
    return [];
  }

  Future<void> deleteDiscussion(String discussionId) async {
    // No-op for web
  }

  // Message methods
  Future<void> saveMessage(Message message, String discussionId) async {
    throw UnsupportedError('Local database not supported on web platform');
  }

  Future<Message?> getMessage(String messageId) async {
    return null;
  }

  Future<List<Message>> getMessages(String discussionId) async {
    return [];
  }

  Future<void> deleteMessage(String messageId) async {
    // No-op for web
  }

  // User methods
  Future<void> saveUser(User user) async {
    throw UnsupportedError('Local database not supported on web platform');
  }

  Future<User?> getUser(String userId) async {
    return null;
  }

  Future<List<User>> getAllUsers() async {
    return [];
  }

  Future<void> deleteUser(String userId) async {
    // No-op for web
  }

  // Additional methods needed by services
  Stream<List<Discussion>> watchAllDiscussions() {
    return Stream.value([]);
  }

  Stream<List<Message>> watchMessagesForDiscussion(String discussionId) {
    return Stream.value([]);
  }

  Stream<List<User>> watchAllUsers() {
    return Stream.value([]);
  }

  Future<List<Message>> getMessagesForDiscussion(String discussionId) async {
    return [];
  }

  Future<void> updateMessage(Message message, String discussionId) async {
    // No-op for web
  }

  Future<void> updateDiscussionById({
    required String id,
    String? title,
    Set<String>? participants,
    DateTime? lastActivity,
    Message? lastMessage,
    bool? isActive,
  }) async {
    // No-op for web
  }
}
