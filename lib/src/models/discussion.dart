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
  /// [isActive] Whether the discussion is active (default: true).
  const factory Discussion({
    required String id,
    required String title,
    required Set<String> participants,
    required DateTime createdAt,
    required DateTime lastActivity,
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
}
