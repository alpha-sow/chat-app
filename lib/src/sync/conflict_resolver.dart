import 'package:dayder_chat/src/src.dart';

/// Handles conflict resolution for data synchronization
class ConflictResolver {
  /// Resolve user conflicts using last activity timestamp
  static User resolveUserConflict(User local, User remote) {
    final localTimestamp = local.lastSeen ?? DateTime(0);
    final remoteTimestamp = remote.lastSeen ?? DateTime(0);

    // Use the user with the more recent activity
    if (localTimestamp.isAfter(remoteTimestamp)) {
      return local;
    } else if (remoteTimestamp.isAfter(localTimestamp)) {
      return remote;
    }

    // If timestamps are equal, prefer online status
    if (local.isOnline && !remote.isOnline) {
      return local;
    } else if (remote.isOnline && !local.isOnline) {
      return remote;
    }

    // Default to remote version to ensure consistency
    return remote;
  }

  /// Resolve discussion conflicts using last activity timestamp
  static Discussion resolveDiscussionConflict(
    Discussion local,
    Discussion remote,
  ) {
    // Always use the version with the most recent activity
    if (local.lastActivity.isAfter(remote.lastActivity)) {
      return local;
    } else if (remote.lastActivity.isAfter(local.lastActivity)) {
      return remote;
    }

    // If same timestamp, merge participants and use remote as base
    final mergedParticipants = Set<String>.from(remote.participants)
      ..addAll(local.participants);

    return remote.copyWith(participants: mergedParticipants);
  }

  /// Resolve message conflicts using timestamp
  static Message resolveMessageConflict(Message local, Message remote) {
    // Messages are typically immutable, but we handle edited messages

    // If one is edited and the other isn't, prefer the edited version
    if (local.edited && !remote.edited) {
      return local;
    } else if (remote.edited && !local.edited) {
      return remote;
    }

    // If both are edited, use the one with later edit time
    if (local.edited && remote.edited) {
      final localEditTime = local.editedAt ?? local.timestamp;
      final remoteEditTime = remote.editedAt ?? remote.timestamp;

      if (localEditTime.isAfter(remoteEditTime)) {
        return local;
      } else if (remoteEditTime.isAfter(localEditTime)) {
        return remote;
      }
    }

    // Merge reactions from both versions
    final mergedReactions = Map<String, Set<String>>.from(remote.reactions);
    local.reactions.forEach((String emoji, Set<String> users) {
      if (mergedReactions.containsKey(emoji)) {
        mergedReactions[emoji] = Set<String>.from(mergedReactions[emoji]!)
          ..addAll(users);
      } else {
        mergedReactions[emoji] = Set<String>.from(users);
      }
    });

    // Merge readBy sets
    final mergedReadBy = Set<String>.from(remote.readBy ?? <String>{})
      ..addAll(local.readBy ?? <String>{});

    // Use remote as base with merged data
    return remote.copyWith(
      reactions: mergedReactions,
      readBy: mergedReadBy.isNotEmpty ? mergedReadBy : null,
    );
  }

  /// Check if local user is newer than remote
  static bool isLocalUserNewer(User local, User remote) {
    final localTimestamp = local.lastSeen ?? DateTime(0);
    final remoteTimestamp = remote.lastSeen ?? DateTime(0);
    return localTimestamp.isAfter(remoteTimestamp);
  }

  /// Check if remote user is newer than local
  static bool isRemoteUserNewer(User remote, User local) {
    final remoteTimestamp = remote.lastSeen ?? DateTime(0);
    final localTimestamp = local.lastSeen ?? DateTime(0);
    return remoteTimestamp.isAfter(localTimestamp);
  }

  /// Check if local discussion is newer than remote
  static bool isLocalDiscussionNewer(
    Discussion local,
    Discussion remote,
  ) {
    return local.lastActivity.isAfter(remote.lastActivity);
  }

  /// Check if remote discussion is newer than local
  static bool isRemoteDiscussionNewer(
    Discussion remote,
    Discussion local,
  ) {
    return remote.lastActivity.isAfter(local.lastActivity);
  }

  /// Check if local message is newer than remote
  static bool isLocalMessageNewer(Message local, Message remote) {
    final localTime = local.editedAt ?? local.timestamp;
    final remoteTime = remote.editedAt ?? remote.timestamp;
    return localTime.isAfter(remoteTime);
  }

  /// Check if remote message is newer than local
  static bool isRemoteMessageNewer(Message remote, Message local) {
    final remoteTime = remote.editedAt ?? remote.timestamp;
    final localTime = local.editedAt ?? local.timestamp;
    return remoteTime.isAfter(localTime);
  }
}
