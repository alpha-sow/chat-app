import 'dart:async';
import 'package:chat_app_package/src/src.dart';
import 'package:chat_app_package/src/utils/utils.dart';

/// Service that synchronizes
/// local Isar database with Firebase Realtime Database
class SyncService {
  SyncService._({
    required DatabaseService localDb,
    required FirebaseRealtimeService firebase,
  }) : _localDb = localDb,
       _firebase = firebase {
    _startConnectionMonitoring();
    _startPeriodicSync();
  }
  static SyncService? _instance;
  final DatabaseService _localDb;
  final FirebaseRealtimeService _firebase;

  // Sync queues for offline operations
  final List<SyncOperation> _pendingSyncOperations = [];
  Timer? _syncTimer;
  StreamSubscription<bool>? _connectionSubscription;
  bool _isOnline = false;
  bool _syncInProgress = false;

  /// instance of sync service
  static SyncService get instance {
    if (_instance == null) {
      throw StateError(
        'SyncService not initialized. Call SyncService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize the sync service with database instances
  static void initialize({
    required DatabaseService localDb,
    required FirebaseRealtimeService firebase,
  }) {
    _instance = SyncService._(
      localDb: localDb,
      firebase: firebase,
    );
  }

  /// Start monitoring connection status
  void _startConnectionMonitoring() {
    _connectionSubscription = _firebase.connectionState.listen((isConnected) {
      _isOnline = isConnected;
      if (isConnected && _pendingSyncOperations.isNotEmpty) {
        _processPendingSyncOperations();
      }
    });
  }

  /// Start periodic sync every 30 seconds when online
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isOnline && !_syncInProgress) {
        syncAll();
      }
    });
  }

  /// Sync all data (discussions, messages, users) bidirectionally
  Future<void> syncAll() async {
    if (_syncInProgress) return;

    _syncInProgress = true;
    try {
      await Future.wait([
        syncUsers(),
        syncDiscussions(),
        syncMessages(),
      ]);
    } finally {
      _syncInProgress = false;
    }
  }

  /// Sync users between local and remote
  Future<void> syncUsers() async {
    try {
      // Get local users
      final localUsers = await _localDb.getAllUsers();

      // Get remote users
      final remoteUsersData = await _firebase.get('users');
      final remoteUsers = <User>[];

      if (remoteUsersData != null) {
        for (final entry in remoteUsersData.entries) {
          try {
            final userData = Map<String, dynamic>.from(entry.value as Map);
            userData['id'] = entry.key;
            remoteUsers.add(User.fromJson(userData));
          } on Exception catch (e) {
            logger.e('Error parsing remote user ${entry.key}: $e');
          }
        }
      }

      // Sync local to remote (upload new/updated local users)
      for (final localUser in localUsers) {
        final remoteUser = remoteUsers
            .where((u) => u.id == localUser.id)
            .firstOrNull;

        if (remoteUser == null ||
            ConflictResolver.isLocalUserNewer(localUser, remoteUser)) {
          await _firebase.set('users/${localUser.id}', localUser.toJson());
        }
      }

      // Sync remote to local (download new/updated remote users)
      for (final remoteUser in remoteUsers) {
        final localUser = localUsers
            .where((u) => u.id == remoteUser.id)
            .firstOrNull;

        if (localUser == null ||
            ConflictResolver.isRemoteUserNewer(remoteUser, localUser)) {
          await _localDb.saveUser(remoteUser);
        } else {
          // Handle conflicts by merging data
          final resolved = ConflictResolver.resolveUserConflict(
            localUser,
            remoteUser,
          );
          if (resolved != localUser) {
            await _localDb.saveUser(resolved);
          }
        }
      }
    } on Exception catch (e) {
      logger.e('Error syncing users: $e');
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.users,
          operation: 'sync_all',
        ),
      );
    }
  }

  /// Sync discussions between local and remote
  Future<void> syncDiscussions() async {
    try {
      // Get local discussions
      final localDiscussions = await _localDb.getAllDiscussions();

      // Get remote discussions
      final remoteDiscussionsData = await _firebase.get('discussions');
      final remoteDiscussions = <DiscussionState>[];

      if (remoteDiscussionsData != null) {
        for (final entry in remoteDiscussionsData.entries) {
          try {
            final discussionData = Map<String, dynamic>.from(
              entry.value as Map,
            );
            discussionData['id'] = entry.key;
            remoteDiscussions.add(DiscussionState.fromJson(discussionData));
          } on Exception catch (e) {
            logger.e('Error parsing remote discussion ${entry.key}: $e');
          }
        }
      }

      // Sync local to remote
      for (final localDiscussion in localDiscussions) {
        final remoteDiscussion = remoteDiscussions
            .where((d) => d.id == localDiscussion.id)
            .firstOrNull;

        if (remoteDiscussion == null ||
            ConflictResolver.isLocalDiscussionNewer(
              localDiscussion,
              remoteDiscussion,
            )) {
          final discussionJson = localDiscussion.toJson()
            ..remove('messages'); // Messages are synced separately
          await _firebase.set(
            'discussions/${localDiscussion.id}',
            discussionJson,
          );
        }
      }

      // Sync remote to local
      for (final remoteDiscussion in remoteDiscussions) {
        final localDiscussion = localDiscussions
            .where((d) => d.id == remoteDiscussion.id)
            .firstOrNull;

        if (localDiscussion == null ||
            ConflictResolver.isRemoteDiscussionNewer(
              remoteDiscussion,
              localDiscussion,
            )) {
          await _localDb.saveDiscussion(remoteDiscussion);
        } else {
          // Handle conflicts by merging data
          final resolved = ConflictResolver.resolveDiscussionConflict(
            localDiscussion,
            remoteDiscussion,
          );
          if (resolved != localDiscussion) {
            await _localDb.saveDiscussion(resolved);
          }
        }
      }
    } on Exception catch (e) {
      logger.e('Error syncing discussions: $e');
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.discussions,
          operation: 'sync_all',
        ),
      );
    }
  }

  /// Sync messages between local and remote
  Future<void> syncMessages() async {
    try {
      final discussions = await _localDb.getAllDiscussions();

      for (final discussion in discussions) {
        await _syncMessagesForDiscussion(discussion.id);
      }
    } on Exception catch (e) {
      logger.e('Error syncing messages: $e');
    }
  }

  /// Sync messages for a specific discussion
  Future<void> _syncMessagesForDiscussion(String discussionId) async {
    try {
      // Get local messages
      final localMessages = await _localDb.getMessagesForDiscussion(
        discussionId,
      );

      // Get remote messages
      final remoteMessagesData = await _firebase.get('messages/$discussionId');
      final remoteMessages = <Message>[];

      if (remoteMessagesData != null) {
        for (final entry in remoteMessagesData.entries) {
          try {
            final messageData = Map<String, dynamic>.from(entry.value as Map);
            messageData['id'] = entry.key;
            remoteMessages.add(Message.fromJson(messageData));
          } on Exception catch (e) {
            logger.e('Error parsing remote message ${entry.key}: $e');
          }
        }
      }

      // Sync local to remote
      for (final localMessage in localMessages) {
        final remoteMessage = remoteMessages
            .where((m) => m.id == localMessage.id)
            .firstOrNull;

        if (remoteMessage == null ||
            ConflictResolver.isLocalMessageNewer(
              localMessage,
              remoteMessage,
            )) {
          await _firebase.set(
            'messages/$discussionId/${localMessage.id}',
            localMessage.toJson(),
          );
        }
      }

      // Sync remote to local
      for (final remoteMessage in remoteMessages) {
        final localMessage = localMessages
            .where((m) => m.id == remoteMessage.id)
            .firstOrNull;

        if (localMessage == null ||
            ConflictResolver.isRemoteMessageNewer(
              remoteMessage,
              localMessage,
            )) {
          await _localDb.saveMessage(remoteMessage, discussionId);
        } else {
          // Handle conflicts by merging data
          final resolved = ConflictResolver.resolveMessageConflict(
            localMessage,
            remoteMessage,
          );
          if (resolved != localMessage) {
            await _localDb.saveMessage(resolved, discussionId);
          }
        }
      }
    } on Exception catch (e) {
      logger.e('Error syncing messages for discussion $discussionId: $e');
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.messages,
          operation: 'sync_discussion',
          discussionId: discussionId,
        ),
      );
    }
  }

  /// Save user locally and sync to remote
  Future<void> saveUser(User user) async {
    await _localDb.saveUser(user);

    if (_isOnline) {
      try {
        await _firebase.set('users/${user.id}', user.toJson());
      } on Exception catch (e) {
        logger.e('Error syncing user to remote: $e');
        _queueSyncOperation(
          SyncOperation(
            type: SyncOperationType.users,
            operation: 'save',
            data: user.toJson(),
          ),
        );
      }
    } else {
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.users,
          operation: 'save',
          data: user.toJson(),
        ),
      );
    }
  }

  /// Save discussion locally and sync to remote
  Future<void> saveDiscussion(DiscussionState discussion) async {
    await _localDb.saveDiscussion(discussion);

    if (_isOnline) {
      try {
        final discussionJson = discussion.toJson()..remove('messages');
        await _firebase.set('discussions/${discussion.id}', discussionJson);
      } on Exception catch (e) {
        logger.e('Error syncing discussion to remote: $e');
        _queueSyncOperation(
          SyncOperation(
            type: SyncOperationType.discussions,
            operation: 'save',
            data: discussion.toJson(),
          ),
        );
      }
    } else {
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.discussions,
          operation: 'save',
          data: discussion.toJson(),
        ),
      );
    }
  }

  /// Save message locally and sync to remote
  Future<void> saveMessage(Message message, String discussionId) async {
    await _localDb.saveMessage(message, discussionId);

    if (_isOnline) {
      try {
        await _firebase.set(
          'messages/$discussionId/${message.id}',
          message.toJson(),
        );
      } on Exception catch (e) {
        logger.e('Error syncing message to remote: $e');
        _queueSyncOperation(
          SyncOperation(
            type: SyncOperationType.messages,
            operation: 'save',
            discussionId: discussionId,
            data: message.toJson(),
          ),
        );
      }
    } else {
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.messages,
          operation: 'save',
          discussionId: discussionId,
          data: message.toJson(),
        ),
      );
    }
  }

  /// Delete user locally and from remote
  Future<void> deleteUser(String userId) async {
    await _localDb.deleteUser(userId);

    if (_isOnline) {
      try {
        await _firebase.delete('users/$userId');
      } on Exception catch (e) {
        logger.e('Error deleting user from remote: $e');
        _queueSyncOperation(
          SyncOperation(
            type: SyncOperationType.users,
            operation: 'delete',
            entityId: userId,
          ),
        );
      }
    } else {
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.users,
          operation: 'delete',
          entityId: userId,
        ),
      );
    }
  }

  /// Delete discussion locally and from remote
  Future<void> deleteDiscussion(String discussionId) async {
    await _localDb.deleteDiscussion(discussionId);

    if (_isOnline) {
      try {
        await _firebase.delete('discussions/$discussionId');
        await _firebase.delete('messages/$discussionId');
      } on Exception catch (e) {
        logger.e('Error deleting discussion from remote: $e');
        _queueSyncOperation(
          SyncOperation(
            type: SyncOperationType.discussions,
            operation: 'delete',
            entityId: discussionId,
          ),
        );
      }
    } else {
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.discussions,
          operation: 'delete',
          entityId: discussionId,
        ),
      );
    }
  }

  /// Delete message locally and from remote
  Future<void> deleteMessage(String messageId, String discussionId) async {
    await _localDb.deleteMessage(messageId);

    if (_isOnline) {
      try {
        await _firebase.delete('messages/$discussionId/$messageId');
      } on Exception catch (e) {
        logger.e('Error deleting message from remote: $e');
        _queueSyncOperation(
          SyncOperation(
            type: SyncOperationType.messages,
            operation: 'delete',
            entityId: messageId,
            discussionId: discussionId,
          ),
        );
      }
    } else {
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.messages,
          operation: 'delete',
          entityId: messageId,
          discussionId: discussionId,
        ),
      );
    }
  }

  /// Listen to real-time changes from Firebase
  void startRealtimeSync() {
    // Listen to user changes
    _firebase.listen('users').listen((data) {
      if (data != null) {
        _handleRemoteUserChanges(data);
      }
    });

    // Listen to discussion changes
    _firebase.listen('discussions').listen((data) {
      if (data != null) {
        _handleRemoteDiscussionChanges(data);
      }
    });

    // Listen to message changes
    _firebase.listen('messages').listen((data) {
      if (data != null) {
        _handleRemoteMessageChanges(data);
      }
    });
  }

  /// Handle remote user changes
  Future<void> _handleRemoteUserChanges(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      try {
        final userData = Map<String, dynamic>.from(entry.value as Map);
        userData['id'] = entry.key;
        final remoteUser = User.fromJson(userData);

        final localUser = await _localDb.getUser(remoteUser.id);
        if (localUser == null ||
            ConflictResolver.isRemoteUserNewer(remoteUser, localUser)) {
          await _localDb.saveUser(remoteUser);
        }
      } on Exception catch (e) {
        logger.e('Error handling remote user change: $e');
      }
    }
  }

  /// Handle remote discussion changes
  Future<void> _handleRemoteDiscussionChanges(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      try {
        final discussionData = Map<String, dynamic>.from(entry.value as Map);
        discussionData['id'] = entry.key;
        final remoteDiscussion = DiscussionState.fromJson(discussionData);

        final localDiscussion = await _localDb.getDiscussion(
          remoteDiscussion.id,
        );
        if (localDiscussion == null ||
            ConflictResolver.isRemoteDiscussionNewer(
              remoteDiscussion,
              localDiscussion,
            )) {
          await _localDb.saveDiscussion(remoteDiscussion);
        }
      } on Exception catch (e) {
        logger.e('Error handling remote discussion change: $e');
      }
    }
  }

  /// Handle remote message changes
  Future<void> _handleRemoteMessageChanges(Map<String, dynamic> data) async {
    for (final discussionEntry in data.entries) {
      final discussionId = discussionEntry.key;
      final messagesData = Map<String, dynamic>.from(
        discussionEntry.value as Map,
      );

      for (final messageEntry in messagesData.entries) {
        try {
          final messageData = Map<String, dynamic>.from(
            messageEntry.value as Map,
          );
          messageData['id'] = messageEntry.key;
          final remoteMessage = Message.fromJson(messageData);

          final localMessage = await _localDb.getMessage(remoteMessage.id);
          if (localMessage == null ||
              ConflictResolver.isRemoteMessageNewer(
                remoteMessage,
                localMessage,
              )) {
            await _localDb.saveMessage(remoteMessage, discussionId);
          }
        } on Exception catch (e) {
          logger.e('Error handling remote message change: $e');
        }
      }
    }
  }

  /// Add operation to sync queue for offline processing
  void _queueSyncOperation(SyncOperation operation) {
    _pendingSyncOperations.add(operation);
  }

  /// Process pending sync operations when connection is restored
  Future<void> _processPendingSyncOperations() async {
    final operations = List<SyncOperation>.from(_pendingSyncOperations);
    _pendingSyncOperations.clear();

    for (final operation in operations) {
      try {
        await _executeSyncOperation(operation);
      } on Exception catch (e) {
        logger.e('Error executing sync operation: $e');
        // Re-queue failed operations
        _pendingSyncOperations.add(operation);
      }
    }
  }

  /// Execute a single sync operation
  Future<void> _executeSyncOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.users:
        await _executeUserSyncOperation(operation);
      case SyncOperationType.discussions:
        await _executeDiscussionSyncOperation(operation);
      case SyncOperationType.messages:
        await _executeMessageSyncOperation(operation);
    }
  }

  /// Execute user sync operation
  Future<void> _executeUserSyncOperation(SyncOperation operation) async {
    switch (operation.operation) {
      case 'save':
        await _firebase.set('users/${operation.data!['id']}', operation.data!);
      case 'delete':
        await _firebase.delete('users/${operation.entityId}');
      case 'sync_all':
        await syncUsers();
    }
  }

  /// Execute discussion sync operation
  Future<void> _executeDiscussionSyncOperation(SyncOperation operation) async {
    switch (operation.operation) {
      case 'save':
        final data = Map<String, dynamic>.from(operation.data!);
        data.remove('messages'); // Messages are synced separately
        await _firebase.set('discussions/${data['id']}', data);
      case 'delete':
        await _firebase.delete('discussions/${operation.entityId}');
        await _firebase.delete('messages/${operation.entityId}');
      case 'sync_all':
        await syncDiscussions();
    }
  }

  /// Execute message sync operation
  Future<void> _executeMessageSyncOperation(SyncOperation operation) async {
    switch (operation.operation) {
      case 'save':
        await _firebase.set(
          'messages/${operation.discussionId}/${operation.data!['id']}',
          operation.data!,
        );
      case 'delete':
        await _firebase.delete(
          'messages/${operation.discussionId}/${operation.entityId}',
        );
      case 'sync_discussion':
        await _syncMessagesForDiscussion(operation.discussionId!);
    }
  }

  /// Get a user from local database
  Future<User?> getUser(String userId) async {
    return _localDb.getUser(userId);
  }

  /// Get a discussion from local database
  Future<DiscussionState?> getDiscussion(String discussionId) async {
    return _localDb.getDiscussion(discussionId);
  }

  /// Get all discussions from local database
  Future<List<DiscussionState>> getAllDiscussions() async {
    return _localDb.getAllDiscussions();
  }

  Stream<List<DiscussionState>> watchAllDiscussions() {
    return _localDb.watchAllDiscussions();
  }

  /// Get sync status
  SyncStatus get syncStatus => SyncStatus(
    isOnline: _isOnline,
    pendingOperations: _pendingSyncOperations.length,
    syncInProgress: _syncInProgress,
  );

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectionSubscription?.cancel();
    _pendingSyncOperations.clear();
    _instance = null;
  }
}
