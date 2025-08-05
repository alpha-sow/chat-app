import 'dart:async';

import 'package:dayder_chat/dayder_chat.dart';
import 'package:uuid/uuid.dart';

class DiscussionService {
  DiscussionService._();
  
  factory DiscussionService.instance() {
    _instance ??= DiscussionService._();
    return _instance!;
  }
  
  static DiscussionService? _instance;
  LocalDatabaseService get _database => LocalDatabaseService.instance();
  SyncService get _syncService => SyncService.instance();

  Stream<List<Discussion>> watchAllDiscussions() {
    return _database.watchAllDiscussions();
  }

  Future<Discussion> withUsers({
    required String title,
    required List<User> users,
    DiscussionType type = DiscussionType.direct,
  }) async {
    final discussion = Discussion(
      id: const Uuid().v4(),
      title: title,
      participants: {...users.map((user) => user.id)},
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
      type: type,
    );
    await _syncService.saveDiscussion(discussion);
    return discussion;
  }

  Discussion tempWithUsers({required String title, required List<User> users}) {
    final discussion = Discussion(
      id: const Uuid().v4(),
      title: title,
      participants: {...users.map((user) => user.id)},
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
    return discussion;
  }

  Future<void> deleteDiscussion(String discussionId) async {
    await _syncService.deleteDiscussion(discussionId);
  }
}
