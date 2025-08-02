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

  /// Loads a discussion service from the database by ID.
  ///
  /// Returns null if the discussion is not found. Automatically loads
  /// associated users from the database.
  factory DiscussionService.create(
    Discussion discussionState,
  ) {
    return DiscussionService._(
      initialState: discussionState,
      persistToDatabase: true,
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

  /// Gets a cached User object by ID.
  ///
  /// [userId] The ID of the user to retrieve.
  ///
  /// Returns the User object if cached, null otherwise.
  User? getUser(String userId) => _users[userId];

  /// Adds a new message to the discussion.
  ///
  /// [senderId] ID of the user sending the message.
  /// [content] The message content.
  /// [type] Type of message (text, image, etc.). Defaults to text.
  /// [replyToId] Optional ID of message being replied to.
  ///
  /// Throws [ArgumentError] if sender is not a participant.
  Message sendMessage(
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

    _state = _state.copyWith(
      messages: updatedMessages,
      lastActivity: DateTime.now(),
    );

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

  /// Loads user information from database for all participants.
  ///
  /// This method fetches and caches User objects for all participants
  /// in the discussion from the database.
  Future<void> loadUsersFromDatabase() async {
    for (final participantId in _state.participants) {
      final user = await LocalDatabaseService.instance.getUser(participantId);
      if (user != null) {
        _users[participantId] = user;
      }
    }
  }

  /// Serialization
  Map<String, dynamic> toJson() => _state.toJson();

  /// Watches all discussions for real-time updates.
  ///
  /// Returns a stream that emits the current list of discussions
  /// whenever they change.
  static Stream<List<Discussion>> get watchAllDiscussions {
    return LocalDatabaseService.instance.watchAllDiscussions();
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
