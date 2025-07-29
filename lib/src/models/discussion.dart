import 'package:chat_app_package/src/src.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'discussion.freezed.dart';
part 'discussion.g.dart';

/// Discussion Model
@freezed
sealed class Discussion with _$Discussion {
  const factory Discussion({
    required String id,
    required String title,
    required Set<String> participants,
    required DateTime createdAt,
    required DateTime lastActivity,
    @Default([]) List<Message> messages,
    @Default(true) bool isActive,
  }) = _Discussion;

  const Discussion._();

  factory Discussion.fromJson(Map<String, dynamic> json) =>
      _$DiscussionFromJson(json);

  factory Discussion.initial({
    required String id,
    required String title,
    List<String>? participants,
  }) {
    final now = DateTime.now();
    return Discussion(
      id: id,
      title: title,
      participants: Set<String>.from(participants ?? []),
      createdAt: now,
      lastActivity: now,
    );
  }

  /// Helper method to generate discussion ID
  static String generateId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  /// Computed properties for lightweight info access
  int get participantCount => participants.length;

  /// Message count
  int get messageCount => messages.length;

  /// Get the last message if available
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Get summary info without creating a separate class
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

  /// Check if user has unread messages
  bool hasUnreadMessages(String userId, DateTime lastReadTimestamp) {
    return messages.any(
      (msg) =>
          msg.timestamp.isAfter(lastReadTimestamp) && msg.senderId != userId,
    );
  }

  /// Get preview text for UI lists
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
