import 'dart:async';

import 'package:chat_app_package/src/src.dart';

/// Service class for managing discussions with real-time messaging capabilities.
/// 
/// This class provides functionality for creating, managing, and interacting with
/// discussions including message handling, participant management, and data 
/// persistence. It supports both local database storage and remote 
/// synchronization through SyncService.
class DiscussionService {
  /// Creates a new discussion service with the specified parameters.
  /// 
  /// [title] The title of the discussion.
  /// [id] Optional discussion ID. If not provided, a UUID will be generated.
  /// [participants] List of participant IDs. Can be empty initially.
  /// [persistToDatabase] Whether to enable database persistence and sync.
  factory DiscussionService({
    required String title,
    String? id,
    List<String>? participants,
    bool persistToDatabase = false,
  }) {
    return DiscussionService._(
      initialState: Discussion.initial(
        id: id ?? Discussion.generateId(),
        title: title,
        participants: participants,
      ),
      persistToDatabase: persistToDatabase,
    );
  }

  /// Creates a discussion service with User objects instead of just IDs.
  /// 
  /// This is useful when you have full User objects and want to cache them
  /// in the discussion for efficient display.
  factory DiscussionService.withUsers({
    required String title,
    String? id,
    List<User>? users,
    bool persistToDatabase = false,
  }) {
    final discussion = DiscussionService._(
      initialState: Discussion.initial(
        id: id ?? Discussion.generateId(),
        title: title,
        participants: users?.map((u) => u.id).toList(),
      ),
      persistToDatabase: persistToDatabase,
    );

    if (users != null) {
      for (final user in users) {
        discussion._users[user.id] = user;

        /// Save user to database if persistence is enabled
        if (persistToDatabase && discussion._syncService != null) {
          discussion._syncService!.saveUser(user);
        }
      }
    }

    return discussion;
  }

  /// Creates a discussion service from a JSON representation.
  /// 
  /// Used for deserializing discussions from storage or network.
  factory DiscussionService.fromJson(
    Map<String, dynamic> json, {
    bool persistToDatabase = false,
  }) {
    return DiscussionService._(
      initialState: Discussion.fromJson(json),
      persistToDatabase: persistToDatabase,
    );
  }

  /// Creates a discussion service from an existing Discussion state.
  /// 
  /// Useful for wrapping existing discussion data with service capabilities.
  factory DiscussionService.fromState(
    Discussion state, {
    bool persistToDatabase = false,
  }) {
    return DiscussionService._(
      initialState: state,
      persistToDatabase: persistToDatabase,
    );
  }

  /// Internal Constructor
  DiscussionService._({
    required Discussion initialState,
    bool persistToDatabase = false,
  }) : _state = initialState,
       _persistToDatabase = persistToDatabase,
       _syncService = persistToDatabase ? SyncService.instance : null,
       _messageStreamController =
           StreamController<MapEntry<DiscussionEvent, dynamic>>.broadcast(),
       _participantStreamController =
           StreamController<MapEntry<ParticipantEvent, String>>.broadcast() {
    /// Save initial state to database if persistence is enabled
    if (_persistToDatabase && _syncService != null) {
      _syncService!.saveDiscussion(_state);
    }
  }
  Discussion _state;
  final bool _persistToDatabase;
  SyncService? _syncService;
  final Map<String, User> _users = {};

  /// Stream controllers for real-time events
  final StreamController<MapEntry<DiscussionEvent, dynamic>>
  _messageStreamController;
  final StreamController<MapEntry<ParticipantEvent, String>>
  _participantStreamController;

  /// Loads a discussion service from the database by ID.
  /// 
  /// Returns null if the discussion is not found. Automatically loads
  /// associated users from the database.
  static Future<DiscussionService?> loadFromDatabase(
    String discussionId,
  ) async {
    final syncService = SyncService.instance;
    final discussionState = await syncService.getDiscussion(discussionId);

    if (discussionState == null) return null;

    final discussion = DiscussionService._(
      initialState: discussionState,
      persistToDatabase: true,
    );

    /// Load users from database
    await discussion.loadUsersFromDatabase();

    return discussion;
  }

  /// Gets the current discussion state.
  Discussion get state => _state;

  /// Gets the discussion ID.
  String get id => _state.id;

  /// Gets the discussion title.
  String get title => _state.title;

  /// Gets the set of participant IDs.
  Set<String> get participants => _state.participants;

  /// Gets all messages in the discussion.
  List<Message> get messages => _state.messages;

  /// Gets when the discussion was created.
  DateTime get createdAt => _state.createdAt;

  /// Gets the timestamp of the last activity.
  DateTime get lastActivity => _state.lastActivity;

  /// Gets whether the discussion is active (not archived).
  bool get isActive => _state.isActive;

  /// Stream of message events for real-time updates.
  Stream<MapEntry<DiscussionEvent, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Stream of participant events for real-time updates.
  Stream<MapEntry<ParticipantEvent, String>> get participantStream =>
      _participantStreamController.stream;

  /// Gets an unmodifiable map of cached users by their IDs.
  Map<String, User> get users => Map.unmodifiable(_users);

  /// Gets a list of all cached User objects.
  List<User> get userList => _users.values.toList();

  /// Gets a cached User object by ID.
  /// 
  /// [userId] The ID of the user to retrieve.
  /// 
  /// Returns the User object if cached, null otherwise.
  User? getUser(String userId) => _users[userId];

  /// Gets the display name for a user.
  /// 
  /// [userId] The ID of the user.
  /// 
  /// Returns the user's display name if cached, otherwise a fallback.
  String getUserDisplayName(String userId) {
    final user = _users[userId];
    return user?.displayName ?? 'User $userId';
  }

  /// Adds a new message to the discussion.
  /// 
  /// [senderId] ID of the user sending the message.
  /// [content] The message content.
  /// [type] Type of message (text, image, etc.). Defaults to text.
  /// [replyToId] Optional ID of message being replied to.
  /// 
  /// Throws [ArgumentError] if sender is not a participant.
  Message addMessage(
    String senderId,
    String content, {
    MessageType type = MessageType.text,
    String? replyToId,
  }) {
    if (!_state.participants.contains(senderId)) {
      throw ArgumentError('Sender is not a participant in this discussion');
    }

    final message = Message.create(
      senderId: senderId,
      content: content,
      type: type,
      replyToId: replyToId,
    );

    _state = _state.copyWith(
      messages: [..._state.messages, message],
      lastActivity: DateTime.now(),
    );

    /// Persist to database if enabled
    if (_persistToDatabase && _syncService != null) {
      _syncService!.saveMessage(message, _state.id);
      _syncService!.saveDiscussion(_state);
    }

    _messageStreamController.add(
      MapEntry(DiscussionEvent.messageAdded, message),
    );
    return message;
  }

  /// Edits an existing message in the discussion.
  /// 
  /// [messageId] ID of the message to edit.
  /// [newContent] New content for the message.
  /// [editorId] ID of the user making the edit.
  /// 
  /// Throws [ArgumentError] if message not found or editor is not the sender.
  Message editMessage(String messageId, String newContent, String editorId) {
    final messageIndex = _state.messages.indexWhere(
      (msg) => msg.id == messageId,
    );
    if (messageIndex == -1) {
      throw ArgumentError('Message not found');
    }

    final originalMessage = _state.messages[messageIndex];
    if (originalMessage.senderId != editorId) {
      throw ArgumentError('Only the sender can edit their message');
    }

    final editedMessage = originalMessage.copyWith(
      content: newContent,
      edited: true,
      editedAt: DateTime.now(),
    );

    final updatedMessages = [..._state.messages];
    updatedMessages[messageIndex] = editedMessage;

    _state = _state.copyWith(messages: updatedMessages);
    _messageStreamController.add(
      MapEntry(DiscussionEvent.messageEdited, editedMessage),
    );

    return editedMessage;
  }

  /// Deletes a message from the discussion.
  /// 
  /// [messageId] ID of the message to delete.
  /// [deleterId] ID of the user requesting deletion.
  /// 
  /// Throws [ArgumentError] if message not found or deleter is not the sender.
  Message deleteMessage(String messageId, String deleterId) {
    final messageIndex = _state.messages.indexWhere(
      (msg) => msg.id == messageId,
    );
    if (messageIndex == -1) {
      throw ArgumentError('Message not found');
    }

    final message = _state.messages[messageIndex];
    if (message.senderId != deleterId) {
      throw ArgumentError('Only the sender can delete their message');
    }

    final updatedMessages = [..._state.messages];
    final deletedMessage = updatedMessages.removeAt(messageIndex);

    _state = _state.copyWith(messages: updatedMessages);

    /// Persist deletion to database if enabled
    if (_persistToDatabase && _syncService != null) {
      _syncService!.deleteMessage(deletedMessage.id, _state.id);
      _syncService!.saveDiscussion(_state);
    }

    _messageStreamController.add(
      MapEntry(DiscussionEvent.messageDeleted, deletedMessage),
    );

    return deletedMessage;
  }

  /// Adds an emoji reaction to a message.
  /// 
  /// [messageId] ID of the message to react to.
  /// [userId] ID of the user adding the reaction.
  /// [emoji] The emoji to add as a reaction.
  /// 
  /// Throws [ArgumentError] if message not found or user not a participant.
  void addReaction(String messageId, String userId, String emoji) {
    final messageIndex = _state.messages.indexWhere(
      (msg) => msg.id == messageId,
    );
    if (messageIndex == -1) {
      throw ArgumentError('Message not found');
    }

    if (!_state.participants.contains(userId)) {
      throw ArgumentError('User is not a participant in this discussion');
    }

    final message = _state.messages[messageIndex];
    final updatedReactions = Map<String, Set<String>>.from(message.reactions);
    updatedReactions.putIfAbsent(emoji, () => <String>{});
    updatedReactions[emoji] = Set<String>.from(updatedReactions[emoji]!)
      ..add(userId);

    final updatedMessage = message.copyWith(reactions: updatedReactions);
    final updatedMessages = [..._state.messages];
    updatedMessages[messageIndex] = updatedMessage;

    _state = _state.copyWith(messages: updatedMessages);

    _messageStreamController.add(
      MapEntry(DiscussionEvent.reactionAdded, {
        'message': updatedMessage,
        'emoji': emoji,
        'userId': userId,
      }),
    );
  }

  /// Removes an emoji reaction from a message.
  /// 
  /// [messageId] ID of the message to remove reaction from.
  /// [userId] ID of the user removing the reaction.
  /// [emoji] The emoji reaction to remove.
  void removeReaction(String messageId, String userId, String emoji) {
    final messageIndex = _state.messages.indexWhere(
      (msg) => msg.id == messageId,
    );
    if (messageIndex == -1) {
      throw ArgumentError('Message not found');
    }

    final message = _state.messages[messageIndex];
    final updatedReactions = Map<String, Set<String>>.from(message.reactions);

    if (updatedReactions.containsKey(emoji)) {
      updatedReactions[emoji] = Set<String>.from(updatedReactions[emoji]!)
        ..remove(userId);

      if (updatedReactions[emoji]!.isEmpty) {
        updatedReactions.remove(emoji);
      }
    }

    final updatedMessage = message.copyWith(reactions: updatedReactions);
    final updatedMessages = [..._state.messages];
    updatedMessages[messageIndex] = updatedMessage;

    _state = _state.copyWith(messages: updatedMessages);

    _messageStreamController.add(
      MapEntry(DiscussionEvent.reactionRemoved, {
        'message': updatedMessage,
        'emoji': emoji,
        'userId': userId,
      }),
    );
  }

  /// Adds a participant to the discussion.
  /// 
  /// [userId] ID of the user to add as a participant.
  /// 
  /// Returns true if the user was added, false if already a participant.
  bool addParticipant(String userId) {
    if (_state.participants.contains(userId)) {
      return false;

      /// Already a participant
    }

    _state = _state.copyWith(
      participants: Set<String>.from(_state.participants)..add(userId),
    );

    _participantStreamController.add(
      MapEntry(ParticipantEvent.participantAdded, userId),
    );
    return true;
  }

  /// Removes a participant from the discussion.
  /// 
  /// [userId] ID of the user to remove from participants.
  /// 
  /// Returns true if the user was removed, false if not a participant.
  bool removeParticipant(String userId) {
    if (!_state.participants.contains(userId)) {
      return false;

      /// Not a participant
    }

    _state = _state.copyWith(
      participants: Set<String>.from(_state.participants)..remove(userId),
    );

    _participantStreamController.add(
      MapEntry(ParticipantEvent.participantRemoved, userId),
    );
    return true;
  }

  /// Checks if a user is a participant in the discussion.
  /// 
  /// [userId] ID of the user to check.
  /// 
  /// Returns true if the user is a participant.
  bool isParticipant(String userId) {
    return _state.participants.contains(userId);
  }

  /// Gets a list of all participant IDs in the discussion.
  /// 
  /// Returns a list of participant user IDs.
  List<String> getParticipants() {
    return _state.participants.toList();
  }

  /// Adds a user as a participant with full user information cached.
  /// 
  /// [user] The User object to add as a participant.
  /// 
  /// Returns true if the user was added, false if already a participant.
  bool addUser(User user) {
    final added = addParticipant(user.id);
    if (added) {
      _users[user.id] = user;

      /// Save user to database if persistence is enabled
      if (_persistToDatabase && _syncService != null) {
        _syncService!.saveUser(user);
      }
    }
    return added;
  }

  /// Removes a user from the discussion and clears cached user data.
  /// 
  /// [userId] ID of the user to remove.
  /// 
  /// Returns true if the user was removed, false if not a participant.
  bool removeUser(String userId) {
    final removed = removeParticipant(userId);
    if (removed) {
      _users.remove(userId);

      /// Note: We don't delete the user from database as they might be in other discussions
    }
    return removed;
  }

  /// Updates cached information for a user in the discussion.
  /// 
  /// [user] Updated User object with new information.
  void updateUser(User user) {
    if (_state.participants.contains(user.id)) {
      _users[user.id] = user;

      /// Save updated user to database if persistence is enabled
      if (_persistToDatabase && _syncService != null) {
        _syncService!.saveUser(user);
      }
    }
  }

  /// Gets a list of currently online users in the discussion.
  /// 
  /// Returns a list of User objects for participants who are online.
  List<User> getActiveUsers() {
    return _users.values.where((user) => user.isOnline).toList();
  }

  /// Gets all users in the discussion regardless of online status.
  /// 
  /// Returns a list of all cached User objects for participants.
  List<User> getUsersInDiscussion() {
    return _users.values.toList();
  }

  /// Gets the count of currently online users in the discussion.
  /// 
  /// Returns the number of participants who are currently online.
  int getOnlineUserCount() {
    return _users.values.where((user) => user.isOnline).length;
  }

  /// Loads user information from database for all participants.
  /// 
  /// This method fetches and caches User objects for all participants
  /// in the discussion from the database.
  Future<void> loadUsersFromDatabase() async {
    if (_syncService != null) {
      for (final participantId in _state.participants) {
        final user = await _syncService!.getUser(participantId);
        if (user != null) {
          _users[participantId] = user;
        }
      }
    }
  }

  /// Retrieves messages from the discussion with pagination.
  /// 
  /// [limit] Maximum number of messages to return (default: 50).
  /// [offset] Number of messages to skip from the beginning (default: 0).
  /// 
  /// Returns a list of Message objects.
  List<Message> getMessages({int limit = 50, int offset = 0}) {
    final startIndex = offset.clamp(0, _state.messages.length);
    final endIndex = (offset + limit).clamp(0, _state.messages.length);
    return _state.messages.sublist(startIndex, endIndex);
  }

  /// Gets all messages sent after a specific timestamp.
  /// 
  /// [timestamp] The cutoff time - only messages after this will be returned.
  /// 
  /// Returns a list of Message objects sent after the timestamp.
  List<Message> getMessagesSince(DateTime timestamp) {
    return _state.messages
        .where((msg) => msg.timestamp.isAfter(timestamp))
        .toList();
  }

  /// Gets messages from a specific user with optional limit.
  /// 
  /// [userId] ID of the user whose messages to retrieve.
  /// [limit] Maximum number of messages to return (default: 20).
  /// 
  /// Returns a list of Message objects from the specified user.
  List<Message> getMessagesFromUser(String userId, {int limit = 20}) {
    return _state.messages
        .where((msg) => msg.senderId == userId)
        .toList()
        .reversed
        .take(limit)
        .toList()
        .reversed
        .toList();
  }

  /// Searches for messages containing specific text.
  /// 
  /// [query] The text to search for in message content.
  /// [limit] Maximum number of results to return (default: 20).
  /// 
  /// Returns a list of Message objects containing the search query.
  List<Message> searchMessages(String query, {int limit = 20}) {
    final lowerQuery = query.toLowerCase();
    return _state.messages
        .where(
          (msg) =>
              msg.content.toLowerCase().contains(lowerQuery) &&
              msg.type == MessageType.text,
        )
        .toList()
        .reversed
        .take(limit)
        .toList()
        .reversed
        .toList();
  }

  /// Marks messages as read by a user up to a specific message.
  /// 
  /// [userId] ID of the user marking messages as read.
  /// [messageId] Optional specific message ID. If not provided, marks
  /// all messages as read.
  void markRead(String userId, {String? messageId}) {
    if (!_state.participants.contains(userId)) {
      throw ArgumentError('User is not a participant in this discussion');
    }

    final targetMessageIndex = messageId != null
        ? _state.messages.indexWhere((msg) => msg.id == messageId)
        : (_state.messages.isNotEmpty ? _state.messages.length - 1 : -1);

    if (targetMessageIndex == -1) return;

    final message = _state.messages[targetMessageIndex];
    final updatedReadBy = Set<String>.from(message.readBy ?? <String>{})
      ..add(userId);
    final updatedMessage = message.copyWith(readBy: updatedReadBy);

    final updatedMessages = [..._state.messages];
    updatedMessages[targetMessageIndex] = updatedMessage;

    _state = _state.copyWith(messages: updatedMessages);
  }

  /// Gets the count of unread messages for a user.
  /// 
  /// [userId] ID of the user to check unread count for.
  /// [lastReadTimestamp] Timestamp of when user last read messages.
  /// 
  /// Returns the number of unread messages for the user.
  int getUnreadCount(String userId, DateTime lastReadTimestamp) {
    if (!_state.participants.contains(userId)) {
      return 0;
    }

    return _state.messages
        .where(
          (msg) =>
              msg.timestamp.isAfter(lastReadTimestamp) &&
              msg.senderId != userId,
        )
        .length;
  }

  /// Discussion Info - now uses computed properties from state
  Map<String, dynamic> getInfo() {
    return _state.summaryInfo;
  }

  /// Get lightweight info for UI lists
  Map<String, dynamic> getSummary() {
    return {
      'id': _state.id,
      'title': _state.title,
      'participantCount': _state.participantCount,
      'messageCount': _state.messageCount,
      'lastActivity': _state.lastActivity,
      'previewText': _state.previewText,
      'isActive': _state.isActive,
    };
  }

  /// Check if user has unread messages
  bool hasUnreadMessages(String userId, DateTime lastReadTimestamp) {
    return _state.hasUnreadMessages(userId, lastReadTimestamp);
  }

  /// Archives the discussion, marking it as inactive.
  void archive() {
    _state = _state.copyWith(isActive: false);
  }

  /// Restores an archived discussion, marking it as active.
  void restore() {
    _state = _state.copyWith(isActive: true);
  }

  /// Updates the discussion title.
  /// 
  /// [newTitle] The new title for the discussion.
  void updateTitle(String newTitle) {
    _state = _state.copyWith(title: newTitle);
  }

  /// Serialization
  Map<String, dynamic> toJson() => _state.toJson();

  /// Database operations
  Future<void> saveToDatabase() async {
    if (_syncService != null) {
      await _syncService!.saveDiscussion(_state);

      /// Save all messages
      for (final message in _state.messages) {
        await _syncService!.saveMessage(message, _state.id);
      }
    }
  }

  /// Watches all discussions for real-time updates.
  /// 
  /// Returns a stream that emits the current list of discussions
  /// whenever they change.
  static Stream<List<Discussion>> watchAllDiscussions() {
    final syncService = SyncService.instance;
    return syncService.watchAllDiscussions();
  }

  /// Deletes a discussion from the database permanently.
  /// 
  /// [discussionId] The ID of the discussion to delete.
  static Future<void> deleteFromDatabase(String discussionId) async {
    final syncService = SyncService.instance;
    await syncService.deleteDiscussion(discussionId);
  }

  /// Disposes of the discussion service and closes streams.
  /// 
  /// Call this when the discussion service is no longer needed
  /// to prevent memory leaks.
  void dispose() {
    _messageStreamController.close();
    _participantStreamController.close();
  }
}
