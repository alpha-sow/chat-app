import 'dart:async';

import 'package:chat_app_package/src/src.dart';

/// Discussion
class Discussion {
  /// Factory constructors
  factory Discussion({
    required String title,
    String? id,
    List<String>? participants,
    bool persistToDatabase = false,
  }) {
    return Discussion._(
      initialState: DiscussionState.initial(
        id: id ?? DiscussionState.generateId(),
        title: title,
        participants: participants,
      ),
      persistToDatabase: persistToDatabase,
    );
  }

  /// Factory constructor with User objects
  factory Discussion.withUsers({
    required String title,
    String? id,
    List<User>? users,
    bool persistToDatabase = false,
  }) {
    final discussion = Discussion._(
      initialState: DiscussionState.initial(
        id: id ?? DiscussionState.generateId(),
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

  /// from Json
  factory Discussion.fromJson(
    Map<String, dynamic> json, {
    bool persistToDatabase = false,
  }) {
    return Discussion._(
      initialState: DiscussionState.fromJson(json),
      persistToDatabase: persistToDatabase,
    );
  }

  /// from state
  factory Discussion.fromState(
    DiscussionState state, {
    bool persistToDatabase = false,
  }) {
    return Discussion._(
      initialState: state,
      persistToDatabase: persistToDatabase,
    );
  }

  /// Internal Constructor
  Discussion._({
    required DiscussionState initialState,
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
  DiscussionState _state;
  final bool _persistToDatabase;
  SyncService? _syncService;
  final Map<String, User> _users = {};

  /// Stream controllers for real-time events
  final StreamController<MapEntry<DiscussionEvent, dynamic>>
  _messageStreamController;
  final StreamController<MapEntry<ParticipantEvent, String>>
  _participantStreamController;

  /// Factory constructor to load from database
  static Future<Discussion?> loadFromDatabase(String discussionId) async {
    final syncService = SyncService.instance;
    final discussionState = await syncService.getDiscussion(discussionId);

    if (discussionState == null) return null;

    final discussion = Discussion._(
      initialState: discussionState,
      persistToDatabase: true,
    );

    /// Load users from database
    await discussion.loadUsersFromDatabase();

    return discussion;
  }

  /// state
  DiscussionState get state => _state;

  /// id
  String get id => _state.id;

  /// title
  String get title => _state.title;

  /// participants
  Set<String> get participants => _state.participants;

  /// message
  List<Message> get messages => _state.messages;

  /// created at
  DateTime get createdAt => _state.createdAt;

  /// last activity
  DateTime get lastActivity => _state.lastActivity;

  /// Is active
  bool get isActive => _state.isActive;

  /// Message Watcher
  Stream<MapEntry<DiscussionEvent, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Participant Watcher
  Stream<MapEntry<ParticipantEvent, String>> get participantStream =>
      _participantStreamController.stream;

  /// User management getters
  Map<String, User> get users => Map.unmodifiable(_users);

  /// User List
  List<User> get userList => _users.values.toList();

  /// User
  User? getUser(String userId) => _users[userId];

  /// Display Name
  String getUserDisplayName(String userId) {
    final user = _users[userId];
    return user?.displayName ?? 'User $userId';
  }

  /// Message Management
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

  /// Participant Management
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

  bool isParticipant(String userId) {
    return _state.participants.contains(userId);
  }

  List<String> getParticipants() {
    return _state.participants.toList();
  }

  /// User-aware participant management
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

  bool removeUser(String userId) {
    final removed = removeParticipant(userId);
    if (removed) {
      _users.remove(userId);

      /// Note: We don't delete the user from database as they might be in other discussions
    }
    return removed;
  }

  void updateUser(User user) {
    if (_state.participants.contains(user.id)) {
      _users[user.id] = user;

      /// Save updated user to database if persistence is enabled
      if (_persistToDatabase && _syncService != null) {
        _syncService!.saveUser(user);
      }
    }
  }

  List<User> getActiveUsers() {
    return _users.values.where((user) => user.isOnline).toList();
  }

  List<User> getUsersInDiscussion() {
    return _users.values.toList();
  }

  int getOnlineUserCount() {
    return _users.values.where((user) => user.isOnline).length;
  }

  /// Load users from database for existing discussions
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

  /// Message Retrieval
  List<Message> getMessages({int limit = 50, int offset = 0}) {
    final startIndex = offset.clamp(0, _state.messages.length);
    final endIndex = (offset + limit).clamp(0, _state.messages.length);
    return _state.messages.sublist(startIndex, endIndex);
  }

  List<Message> getMessagesSince(DateTime timestamp) {
    return _state.messages
        .where((msg) => msg.timestamp.isAfter(timestamp))
        .toList();
  }

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

  /// Discussion Management
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

  void archive() {
    _state = _state.copyWith(isActive: false);
  }

  void restore() {
    _state = _state.copyWith(isActive: true);
  }

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

  /// Static Watch discussion state
  static Stream<List<DiscussionState>> watchAllDiscussions() {
    final syncService = SyncService.instance;
    return syncService.watchAllDiscussions();
  }

  /// Static delete from data
  static Future<void> deleteFromDatabase(String discussionId) async {
    final syncService = SyncService.instance;
    await syncService.deleteDiscussion(discussionId);
  }

  /// Cleanup
  void dispose() {
    _messageStreamController.close();
    _participantStreamController.close();
  }
}
