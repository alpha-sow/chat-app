import 'dart:async';
import 'package:chat_app_package/src/src.dart';
import 'package:chat_app_package/src/utils/utils.dart';

/// Service that synchronizes local Isar database with Firebase Realtime Database.
///
/// This service provides bidirectional synchronization between local storage
/// and remote Firebase, handling offline scenarios with operation queuing
/// and conflict resolution. It supports real-time updates and automatic
/// retry mechanisms for failed operations.
class SyncService {
  SyncService._({
    required DatabaseService localDb,
    required FirebaseRealtimeService firebase,
    required String currentUserId,
  }) : _localDb = localDb,
       _firebase = firebase,
       _currentUserId = currentUserId {
    _startConnectionMonitoring();
    _startPeriodicSync();
  }
  static SyncService? _instance;
  final DatabaseService _localDb;
  final FirebaseRealtimeService _firebase;
  final String _currentUserId;

  // Sync queues for offline operations
  final List<SyncOperation> _pendingSyncOperations = [];
  Timer? _syncTimer;
  StreamSubscription<bool>? _connectionSubscription;
  bool _isOnline = false;
  bool _syncInProgress = false;

  /// Gets the singleton instance of the sync service.
  ///
  /// Throws [StateError] if the service hasn't been initialized.
  static SyncService get instance {
    if (_instance == null) {
      throw StateError(
        'SyncService not initialized. Call SyncService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initializes the sync service with required database instances.
  ///
  /// Must be called before accessing the [instance]. This sets up the
  /// singleton with local database and Firebase service instances.
  ///
  /// [localDb] The local Isar database service.
  /// [firebase] The Firebase Realtime Database service.
  /// [currentUserId] The ID of the current user for scoping data.
  static void initialize({
    required DatabaseService localDb,
    required FirebaseRealtimeService firebase,
    required String currentUserId,
  }) {
    _instance = SyncService._(
      localDb: localDb,
      firebase: firebase,
      currentUserId: currentUserId,
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

  /// Synchronizes all data types bidirectionally with remote database.
  ///
  /// Performs a complete sync of users, discussions, and messages between
  /// local and remote databases. Operations are performed in parallel
  /// for efficiency.
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

  /// Synchronizes user data between local and remote databases.
  ///
  /// Compares local and remote users, uploading newer local changes
  /// and downloading newer remote changes. Handles conflicts using
  /// the conflict resolver.
  Future<void> syncUsers() async {
    try {
      // Get local users
      final localUsers = await _localDb.getAllUsers();

      // Get remote users
      final remoteUsersData = await _firebase.get('users/$_currentUserId/contacts');
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
          await _firebase.set('users/$_currentUserId/contacts/${localUser.id}', localUser.toJson());
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

  /// Synchronizes discussion data between local and remote databases.
  ///
  /// Note: Messages are synced separately. This only syncs discussion
  /// metadata like title, participants, and timestamps.
  Future<void> syncDiscussions() async {
    try {
      // Get local discussions
      final localDiscussions = await _localDb.getAllDiscussions();

      // Get remote discussions
      final remoteDiscussionsData = await _firebase.get('users/$_currentUserId/discussions');
      final remoteDiscussions = <Discussion>[];

      if (remoteDiscussionsData != null) {
        for (final entry in remoteDiscussionsData.entries) {
          try {
            final discussionData = Map<String, dynamic>.from(
              entry.value as Map,
            );
            discussionData['id'] = entry.key;
            remoteDiscussions.add(Discussion.fromJson(discussionData));
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
            'users/$_currentUserId/discussions/${localDiscussion.id}',
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

  /// Synchronizes all messages across all discussions.
  ///
  /// Iterates through all discussions and syncs their messages
  /// individually for better error isolation.
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
      final remoteMessagesData = await _firebase.get('users/$_currentUserId/messages/$discussionId');
      final remoteMessages = <Message>[];

      if (remoteMessagesData != null) {
        for (final entry in remoteMessagesData.entries) {
          try {
            final messageData = Map<String, dynamic>.from(entry.value as Map);
            messageData['id'] = entry.key;

            // Validate required fields before creating Message
            if (!_isValidMessageData(messageData)) {
              logger.w(
                'Skipping invalid remote '
                'message ${entry.key}: missing required fields',
              );
              continue;
            }

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
            'users/$_currentUserId/messages/$discussionId/${localMessage.id}',
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

  /// Saves a user locally and synchronizes to remote database.
  ///
  /// If online, immediately syncs to remote. If offline, queues the
  /// operation for later execution when connection is restored.
  ///
  /// [user] The user object to save and sync.
  Future<void> saveUser(User user) async {
    await _localDb.saveUser(user);

    if (_isOnline) {
      try {
        await _firebase.set('users/$_currentUserId/contacts/${user.id}', user.toJson());
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

  /// Saves a discussion locally and synchronizes to remote database.
  ///
  /// Messages are excluded from remote sync as they're handled separately.
  /// If offline, queues the operation for later execution.
  ///
  /// [discussion] The discussion object to save and sync.
  Future<void> saveDiscussion(Discussion discussion) async {
    await _localDb.saveDiscussion(discussion);

    if (_isOnline) {
      try {
        final discussionJson = discussion.toJson()..remove('messages');
        await _firebase.set('users/$_currentUserId/discussions/${discussion.id}', discussionJson);
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

  /// Saves a message locally and synchronizes to remote database.
  ///
  /// [message] The message object to save and sync.
  /// [discussionId] The ID of the discussion this message belongs to.
  Future<void> saveMessage(Message message, String discussionId) async {
    await _localDb.saveMessage(message, discussionId);

    if (_isOnline) {
      try {
        await _firebase.set(
          'users/$_currentUserId/messages/$discussionId/${message.id}',
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

  /// Updates an existing message in both local and remote databases.
  ///
  /// [message] The updated message object.
  /// [discussionId] The ID of the discussion this message belongs to.
  Future<void> updateMessage(Message message, String discussionId) async {
    await _localDb.updateMessage(message, discussionId);

    if (_isOnline) {
      try {
        await _firebase.set(
          'users/$_currentUserId/messages/$discussionId/${message.id}',
          message.toJson(),
        );
      } on Exception catch (e) {
        logger.e('Error updating message in remote: $e');
        _queueSyncOperation(
          SyncOperation(
            type: SyncOperationType.messages,
            operation: 'update',
            discussionId: discussionId,
            data: message.toJson(),
          ),
        );
      }
    } else {
      _queueSyncOperation(
        SyncOperation(
          type: SyncOperationType.messages,
          operation: 'update',
          discussionId: discussionId,
          data: message.toJson(),
        ),
      );
    }
  }

  /// Deletes a user from both local and remote databases.
  ///
  /// [userId] The ID of the user to delete.
  Future<void> deleteUser(String userId) async {
    await _localDb.deleteUser(userId);

    if (_isOnline) {
      try {
        await _firebase.delete('users/$_currentUserId/contacts/$userId');
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

  /// Deletes a discussion and its messages from both databases.
  ///
  /// Removes the discussion and all associated messages from both
  /// local and remote storage.
  ///
  /// [discussionId] The ID of the discussion to delete.
  Future<void> deleteDiscussion(String discussionId) async {
    await _localDb.deleteDiscussion(discussionId);

    if (_isOnline) {
      try {
        await _firebase.delete('users/$_currentUserId/discussions/$discussionId');
        await _firebase.delete('users/$_currentUserId/messages/$discussionId');
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

  /// Deletes a message from both local and remote databases.
  ///
  /// [messageId] The ID of the message to delete.
  /// [discussionId] The ID of the discussion containing the message.
  Future<void> deleteMessage(String messageId, String discussionId) async {
    await _localDb.deleteMessage(messageId);

    if (_isOnline) {
      try {
        await _firebase.delete('users/$_currentUserId/messages/$discussionId/$messageId');
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

  /// Starts listening for real-time changes from Firebase.
  ///
  /// Sets up listeners for users, discussions, and messages that will
  /// automatically update local data when remote changes occur.
  void startRealtimeSync() {
    // Listen to user changes
    _firebase.listen('users/$_currentUserId/contacts').listen((data) {
      if (data != null) {
        _handleRemoteUserChanges(data);
      }
    });

    // Listen to discussion changes
    _firebase.listen('users/$_currentUserId/discussions').listen((data) {
      if (data != null) {
        _handleRemoteDiscussionChanges(data);
      }
    });

    // Listen to message changes
    _firebase.listen('users/$_currentUserId/messages').listen((data) {
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
        final remoteDiscussion = Discussion.fromJson(discussionData);

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

          // Validate required fields before creating Message
          if (!_isValidMessageData(messageData)) {
            logger.w(
              'Skipping invalid remote message ${messageEntry.key}: missing required fields',
            );
            continue;
          }

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
        await _firebase.set('users/$_currentUserId/contacts/${operation.data!['id']}', operation.data!);
      case 'delete':
        await _firebase.delete('users/$_currentUserId/contacts/${operation.entityId}');
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
        await _firebase.set('users/$_currentUserId/discussions/${data['id']}', data);
      case 'delete':
        await _firebase.delete('users/$_currentUserId/discussions/${operation.entityId}');
        await _firebase.delete('users/$_currentUserId/messages/${operation.entityId}');
      case 'sync_all':
        await syncDiscussions();
    }
  }

  /// Execute message sync operation
  Future<void> _executeMessageSyncOperation(SyncOperation operation) async {
    switch (operation.operation) {
      case 'save':
        await _firebase.set(
          'users/$_currentUserId/messages/${operation.discussionId}/${operation.data!['id']}',
          operation.data!,
        );
      case 'delete':
        await _firebase.delete(
          'users/$_currentUserId/messages/${operation.discussionId}/${operation.entityId}',
        );
      case 'sync_discussion':
        await _syncMessagesForDiscussion(operation.discussionId!);
    }
  }

  /// Retrieves a user from the local database.
  ///
  /// [userId] The ID of the user to retrieve.
  ///
  /// Returns the User object if found, null otherwise.
  Future<User?> getUser(String userId) async {
    return _localDb.getUser(userId);
  }

  /// Retrieves a discussion from the local database.
  ///
  /// [discussionId] The ID of the discussion to retrieve.
  ///
  /// Returns the Discussion object if found, null otherwise.
  Future<Discussion?> getDiscussion(String discussionId) async {
    return _localDb.getDiscussion(discussionId);
  }

  /// Retrieves all discussions from the local database.
  ///
  /// Returns a list of all Discussion objects stored locally.
  Future<List<Discussion>> getAllDiscussions() async {
    return _localDb.getAllDiscussions();
  }

  /// Watches all discussions for real-time updates.
  ///
  /// Returns a stream that emits the current list of discussions
  /// whenever they change in the local database.
  Stream<List<Discussion>> watchAllDiscussions() {
    return _localDb.watchAllDiscussions();
  }

  /// Gets the current synchronization status.
  ///
  /// Returns information about online state, pending operations,
  /// and whether a sync is currently in progress.
  SyncStatus get syncStatus => SyncStatus(
    isOnline: _isOnline,
    pendingOperations: _pendingSyncOperations.length,
    syncInProgress: _syncInProgress,
  );

  /// Validates that message data contains all required fields.
  ///
  /// [messageData] The message data to validate.
  ///
  /// Returns true if the message data is valid, false otherwise.
  bool _isValidMessageData(Map<String, dynamic> messageData) {
    // Check required fields
    if (messageData['id'] == null || messageData['id'].toString().isEmpty) {
      return false;
    }
    if (messageData['senderId'] == null ||
        messageData['senderId'].toString().isEmpty) {
      return false;
    }
    if (messageData['content'] == null) {
      return false;
    }
    if (messageData['timestamp'] == null) {
      return false;
    }
    return true;
  }

  /// Disposes of the sync service and releases resources.
  ///
  /// Cancels timers, closes subscriptions, clears pending operations,
  /// and nullifies the singleton instance.
  void dispose() {
    _syncTimer?.cancel();
    _connectionSubscription?.cancel();
    _pendingSyncOperations.clear();
    _instance = null;
  }
}
