import 'dart:async';
import 'dart:convert';

import 'package:chat_app_package/src/src.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Web implementation using SharedPreferences for local storage
class LocalDatabaseService {
  LocalDatabaseService._();
  static LocalDatabaseService? _instance;
  static SharedPreferences? _prefs;

  static LocalDatabaseService get instance {
    _instance ??= LocalDatabaseService._();
    return _instance!;
  }

  /// Initializes SharedPreferences for web storage
  static Future<void> initialize({required String directory}) async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Discussion methods
  Future<void> saveDiscussion(Discussion discussion) async {
    final discussions = await getAllDiscussions();
    final index = discussions.indexWhere((d) => d.id == discussion.id);
    
    if (index >= 0) {
      discussions[index] = discussion;
    } else {
      discussions.add(discussion);
    }
    
    final discussionsJson = discussions.map((d) => d.toJson()).toList();
    await prefs.setString('discussions', jsonEncode(discussionsJson));
  }

  Future<Discussion?> getDiscussion(String discussionId) async {
    final discussions = await getAllDiscussions();
    try {
      return discussions.firstWhere((d) => d.id == discussionId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Discussion>> getAllDiscussions() async {
    final discussionsString = prefs.getString('discussions');
    if (discussionsString == null) return [];
    
    try {
      final List<dynamic> discussionsJson = jsonDecode(discussionsString) as List<dynamic>;
      return discussionsJson
          .map((json) => Discussion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteDiscussion(String discussionId) async {
    final discussions = await getAllDiscussions();
    discussions.removeWhere((d) => d.id == discussionId);
    
    final discussionsJson = discussions.map((d) => d.toJson()).toList();
    await prefs.setString('discussions', jsonEncode(discussionsJson));
    
    // Also delete related messages
    final messages = await getAllMessages();
    messages.removeWhere((m) => m['discussion_id'] == discussionId);
    await prefs.setString('messages', jsonEncode(messages));
  }

  // Message methods
  Future<void> saveMessage(Message message, String discussionId) async {
    final messages = await getAllMessages();
    final messageData = {
      'id': message.id,
      'discussion_id': discussionId,
      'sender_id': message.senderId,
      'content': message.content,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'type': message.type.toString(),
      'reply_to_id': message.replyToId,
    };
    
    final index = messages.indexWhere((m) => m['id'] == message.id);
    if (index >= 0) {
      messages[index] = messageData;
    } else {
      messages.add(messageData);
    }
    
    await prefs.setString('messages', jsonEncode(messages));
  }

  Future<Message?> getMessage(String messageId) async {
    final messages = await getAllMessages();
    try {
      final messageData = messages.firstWhere((m) => m['id'] == messageId);
      return _messageFromMap(messageData);
    } catch (e) {
      return null;
    }
  }

  Future<List<Message>> getMessagesForDiscussion(
    String discussionId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final messages = await getAllMessages();
    final discussionMessages = messages
        .where((m) => m['discussion_id'] == discussionId)
        .map(_messageFromMap)
        .toList();
    
    discussionMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    final endIndex = (offset + limit).clamp(0, discussionMessages.length);
    return discussionMessages.sublist(offset.clamp(0, discussionMessages.length), endIndex);
  }

  Future<void> updateMessage(Message message, String discussionId) async {
    await saveMessage(message, discussionId);
  }

  Future<void> deleteMessage(String messageId) async {
    final messages = await getAllMessages();
    messages.removeWhere((m) => m['id'] == messageId);
    await prefs.setString('messages', jsonEncode(messages));
  }

  // Legacy method for compatibility
  Future<List<Message>> getMessages(String discussionId) async {
    return getMessagesForDiscussion(discussionId);
  }

  // User methods
  Future<void> saveUser(User user) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    
    final usersJson = users.map((u) => u.toJson()).toList();
    await prefs.setString('users', jsonEncode(usersJson));
  }

  Future<User?> getUser(String userId) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    final usersString = prefs.getString('users');
    if (usersString == null) return [];
    
    try {
      final List<dynamic> usersJson = jsonDecode(usersString) as List<dynamic>;
      return usersJson
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteUser(String userId) async {
    final users = await getAllUsers();
    users.removeWhere((u) => u.id == userId);
    
    final usersJson = users.map((u) => u.toJson()).toList();
    await prefs.setString('users', jsonEncode(usersJson));
  }

  // Watch methods (simplified for web - periodic updates)
  Stream<List<Discussion>> watchAllDiscussions() {
    return Stream.periodic(const Duration(seconds: 1), (_) => getAllDiscussions())
        .asyncMap((future) => future)
        .distinct();
  }

  Stream<List<Message>> watchMessagesForDiscussion(String discussionId) {
    return Stream.periodic(const Duration(seconds: 1), (_) => getMessagesForDiscussion(discussionId))
        .asyncMap((future) => future)
        .distinct();
  }

  Stream<List<User>> watchAllUsers() {
    return Stream.periodic(const Duration(seconds: 1), (_) => getAllUsers())
        .asyncMap((future) => future)
        .distinct();
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

  // Helper methods
  Future<List<Map<String, dynamic>>> getAllMessages() async {
    final messagesString = prefs.getString('messages');
    if (messagesString == null) return [];
    
    try {
      final List<dynamic> messagesJson = jsonDecode(messagesString) as List<dynamic>;
      return messagesJson.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Message _messageFromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
      replyToId: map['reply_to_id'] as String?,
    );
  }

}