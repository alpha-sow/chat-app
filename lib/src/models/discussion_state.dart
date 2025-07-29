import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chat_app_package/src/src.dart';
import 'package:uuid/uuid.dart';

part 'discussion_state.freezed.dart';
part 'discussion_state.g.dart';

@freezed
sealed class DiscussionState with _$DiscussionState {
  const factory DiscussionState({
    required String id,
    required String title,
    required Set<String> participants,
    @Default([]) List<Message> messages,
    required DateTime createdAt,
    required DateTime lastActivity,
    @Default(true) bool isActive,
  }) = _DiscussionState;

  const DiscussionState._();

  factory DiscussionState.fromJson(Map<String, dynamic> json) =>
      _$DiscussionStateFromJson(json);

  factory DiscussionState.initial({
    required String id,
    required String title,
    List<String>? participants,
  }) {
    final now = DateTime.now();
    return DiscussionState(
      id: id,
      title: title,
      participants: Set<String>.from(participants ?? []),
      messages: const <Message>[],
      createdAt: now,
      lastActivity: now,
    );
  }

  // Helper method to generate discussion ID
  static String generateId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  // Computed properties for lightweight info access
  int get participantCount => participants.length;
  int get messageCount => messages.length;

  // Get the last message if available
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  // Get summary info without creating a separate class
  Map<String, dynamic> get summaryInfo => {
    'id': id,
    'title': title,
    'participantCount': participantCount,
    'messageCount': messageCount,
    'createdAt': createdAt.toIso8601String(),
    'lastActivity': lastActivity.toIso8601String(),
    'isActive': isActive,
    'lastMessage': lastMessage?.content,
  };

  // Check if user has unread messages
  bool hasUnreadMessages(String userId, DateTime lastReadTimestamp) {
    return messages.any(
      (msg) =>
          msg.timestamp.isAfter(lastReadTimestamp) && msg.senderId != userId,
    );
  }

  // Get preview text for UI lists
  String get previewText {
    if (messages.isEmpty) return 'No messages yet';
    final lastMsg = messages.last;
    switch (lastMsg.type) {
      case MessageType.text:
        return lastMsg.content.length > 50
            ? '${lastMsg.content.substring(0, 50)}...'
            : lastMsg.content;
      case MessageType.image:
        return '📷 Image';
      case MessageType.file:
        return '📎 File';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.video:
        return '🎥 Video';
    }
  }
}
