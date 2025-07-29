import 'package:chat_app_package/src/src.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'discussion.freezed.dart';
part 'discussion.g.dart';

/// Immutable model representing a chat discussion.
/// 
/// A discussion contains metadata about a chat conversation including
/// participants, messages, timestamps, and activity status. This model
/// uses Freezed for immutability and includes computed properties for
/// UI convenience.
@freezed
sealed class Discussion with _$Discussion {
  /// Creates a new Discussion instance.
  /// 
  /// [id] Unique identifier for the discussion.
  /// [title] Display title of the discussion.
  /// [participants] Set of participant user IDs.
  /// [createdAt] When the discussion was created.
  /// [lastActivity] Timestamp of the last activity.
  /// [messages] List of messages in the discussion (default: empty).
  /// [isActive] Whether the discussion is active (default: true).
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

  /// Creates a new discussion with initial values.
  /// 
  /// [id] Unique identifier for the discussion.
  /// [title] Display title of the discussion.
  /// [participants] Optional list of initial participant IDs.
  /// 
  /// Returns a Discussion with current timestamps and empty messages.
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

  /// Generates a unique ID for a new discussion.
  /// 
  /// Returns a UUID v4 string suitable for use as a discussion ID.
  static String generateId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  /// Gets the number of participants in the discussion.
  int get participantCount => participants.length;

  /// Gets the total number of messages in the discussion.
  int get messageCount => messages.length;

  /// Gets the most recent message in the discussion.
  /// 
  /// Returns the last Message if any exist, null if discussion is empty.
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Gets a summary of discussion information as a map.
  /// 
  /// Returns a map containing key discussion metadata for display purposes.
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

  /// Checks if a user has unread messages in this discussion.
  /// 
  /// [userId] The ID of the user to check for.
  /// [lastReadTimestamp] When the user last read messages.
  /// 
  /// Returns true if there are messages after the timestamp from other users.
  bool hasUnreadMessages(String userId, DateTime lastReadTimestamp) {
    return messages.any(
      (msg) =>
          msg.timestamp.isAfter(lastReadTimestamp) && msg.senderId != userId,
    );
  }

  /// Gets preview text for displaying in discussion lists.
  /// 
  /// Returns a short preview of the last message content, or a placeholder
  /// if no messages exist. Handles different message types appropriately.
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
