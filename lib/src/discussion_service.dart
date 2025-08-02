import 'dart:async';

import 'package:chat_app_package/chat_app_package.dart';
import 'package:uuid/uuid.dart';

class DiscussionService {
  DiscussionService._();
  static DiscussionService? _instance;

  static DiscussionService get instance {
    _instance ??= DiscussionService._();
    return _instance!;
  }

  LocalDatabaseService get _database => LocalDatabaseService.instance;
  SyncService get _syncService => SyncService.instance;

  Stream<List<Discussion>> watchAllDiscussions() {
    return _database.watchAllDiscussions();
  }

  Discussion withUsers({required String title, required List<User> users}) {
    final discussion = Discussion(
      id: const Uuid().v4(),
      title: title,
      participants: {...users.map((user) => user.id)},
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
    _database.saveDiscussion(discussion);
    unawaited(_syncService.syncDiscussions());
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

  void deleteDiscussion(String discussionId) {
    _database.deleteDiscussion(discussionId);
    unawaited(_syncService.syncDiscussions());
  }
}
