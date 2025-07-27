import 'dart:async';

import 'package:tchat_app/src/src.dart';

class Discussion {
  DiscussionState _state;

  // Stream controllers for real-time events
  final StreamController<MapEntry<DiscussionEvent, dynamic>>
  _messageStreamController;
  final StreamController<MapEntry<ParticipantEvent, String>>
  _participantStreamController;

  Discussion._({
    required DiscussionState initialState,
  }) : _state = initialState,
       _messageStreamController =
           StreamController<MapEntry<DiscussionEvent, dynamic>>.broadcast(),
       _participantStreamController =
           StreamController<MapEntry<ParticipantEvent, String>>.broadcast();

  // Factory constructors
  factory Discussion({
    String? id,
    required String title,
    List<String>? participants,
  }) {
    return Discussion._(
      initialState: DiscussionState.initial(
        id: id ?? DiscussionState.generateId(),
        title: title,
        participants: participants,
      ),
    );
  }

  factory Discussion.fromState(DiscussionState state) {
    return Discussion._(initialState: state);
  }

  factory Discussion.fromJson(Map<String, dynamic> json) {
    return Discussion._(initialState: DiscussionState.fromJson(json));
  }

  // Getters
  DiscussionState get state => _state;
  String get id => _state.id;
  String get title => _state.title;
  Set<String> get participants => _state.participants;
  List<Message> get messages => _state.messages;
  DateTime get createdAt => _state.createdAt;
  DateTime get lastActivity => _state.lastActivity;
  bool get isActive => _state.isActive;

  Stream<MapEntry<DiscussionEvent, dynamic>> get messageStream =>
      _messageStreamController.stream;
  Stream<MapEntry<ParticipantEvent, String>> get participantStream =>
      _participantStreamController.stream;

  // Message Management
  Message addMessage(
    String senderId,
    String content, {
    MessageType type = MessageType.text,
  }) {
    if (!_state.participants.contains(senderId)) {
      throw ArgumentError('Sender is not a participant in this discussion');
    }

    final message = Message.create(
      senderId: senderId,
      content: content,
      type: type,
    );

    _state = _state.copyWith(
      messages: [..._state.messages, message],
      lastActivity: DateTime.now(),
    );

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

  // Participant Management
  bool addParticipant(String userId) {
    if (_state.participants.contains(userId)) {
      return false; // Already a participant
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
      return false; // Not a participant
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

  // Message Retrieval
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

  // Discussion Management
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

  // Discussion Info - now uses computed properties from state
  Map<String, dynamic> getInfo() {
    return _state.summaryInfo;
  }

  // Get lightweight info for UI lists
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

  // Check if user has unread messages
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

  // Serialization
  Map<String, dynamic> toJson() => _state.toJson();

  // Cleanup
  void dispose() {
    _messageStreamController.close();
    _participantStreamController.close();
  }
}
