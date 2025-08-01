import 'dart:async';

import 'package:chat_app_package/src/src.dart';

/// Service class for managing users in the chat application.
///
/// This service provides functionality for creating, updating, and managing
/// users with real-time capabilities, presence tracking, and data persistence.
/// It supports both local database storage and remote synchronization.
class UserService {
  UserService._();
  static UserService? _instance;
  static SyncService? _syncService;

  /// Gets the singleton instance of the user service.
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  /// Cache for storing user objects in memory for quick access
  final Map<String, User> _userCache = {};

  /// Stream controller for user events (online/offline, status changes)
  final StreamController<MapEntry<UserEvent, User>> _userEventController =
      StreamController<MapEntry<UserEvent, User>>.broadcast();

  /// Initializes the user service with database persistence
  static Future<void> initialize({bool enableSync = true}) async {
    if (enableSync) {
      _syncService = SyncService.instance;
    }
  }

  /// Creates a new user and saves it to the database
  ///
  /// [name] The user's display name
  /// [email] Optional email address
  /// [phoneNumber] Optional phone number
  /// [avatarUrl] Optional avatar image URL
  ///
  /// Returns the created User object
  Future<User> createUser({
    required String name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final user = User.create(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
    );

    // Cache the user
    _userCache[user.id] = user;

    // Save to database
    await LocalDatabaseService.instance.saveUser(user);

    // Sync to remote if enabled
    if (_syncService != null) {
      await _syncService!.saveUser(user);
    }

    // Emit user created event
    _userEventController.add(MapEntry(UserEvent.created, user));

    return user;
  }

  /// Creates a guest user (temporary user with limited features)
  ///
  /// [name] The guest user's display name
  ///
  /// Returns the created guest User object
  Future<User> createGuestUser(String name) async {
    final user = User.guest(name);

    // Cache the user (guests are not persisted to database)
    _userCache[user.id] = user;

    // Emit user created event
    _userEventController.add(MapEntry(UserEvent.created, user));

    return user;
  }

  /// Retrieves a user by ID
  ///
  /// First checks the cache, then the local database
  ///
  /// [userId] The ID of the user to retrieve
  ///
  /// Returns the User object if found, null otherwise
  Future<User?> getUser(String userId) async {
    // Check cache first
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    // Check local database
    final user = await LocalDatabaseService.instance.getUser(userId);
    if (user != null) {
      // Cache the user for future requests
      _userCache[userId] = user;
      return user;
    }

    return null;
  }

  /// Gets all users from the local database
  ///
  /// Returns a list of all User objects
  Future<List<User>> getAllUsers() async {
    final users = await LocalDatabaseService.instance.getAllUsers();

    // Update cache with all users
    for (final user in users) {
      _userCache[user.id] = user;
    }

    return users;
  }

  /// Updates an existing user
  ///
  /// [user] The updated user object
  ///
  /// Returns the updated User object
  /// Throws [ArgumentError] if the user doesn't exist
  Future<User> updateUser(User user) async {
    final existingUser = await getUser(user.id);
    if (existingUser == null) {
      throw ArgumentError('User with ID ${user.id} not found');
    }

    _userCache[user.id] = user;

    if (!user.isGuest) {
      await LocalDatabaseService.instance.saveUser(user);

      if (_syncService != null) {
        await _syncService!.saveUser(user);
      }
    }

    _userEventController.add(MapEntry(UserEvent.updated, user));

    return user;
  }

  /// Sets a user as online
  ///
  /// [userId] The ID of the user to set online
  ///
  /// Returns the updated User object
  /// Throws [ArgumentError] if the user doesn't exist
  Future<User> setUserOnline(String userId) async {
    final user = await getUser(userId);
    if (user == null) {
      throw ArgumentError('User with ID $userId not found');
    }

    final updatedUser = user.setOnline();
    await updateUser(updatedUser);

    // Emit presence change event
    _userEventController.add(MapEntry(UserEvent.presenceChanged, updatedUser));

    return updatedUser;
  }

  /// Sets a user as offline
  ///
  /// [userId] The ID of the user to set offline
  ///
  /// Returns the updated User object
  /// Throws [ArgumentError] if the user doesn't exist
  Future<User> setUserOffline(String userId) async {
    final user = await getUser(userId);
    if (user == null) {
      throw ArgumentError('User with ID $userId not found');
    }

    final updatedUser = user.setOffline();
    await updateUser(updatedUser);

    // Emit presence change event
    _userEventController.add(MapEntry(UserEvent.presenceChanged, updatedUser));

    return updatedUser;
  }

  /// Updates a user's status message
  ///
  /// [userId] The ID of the user
  /// [status] The new status message
  ///
  /// Returns the updated User object
  /// Throws [ArgumentError] if the user doesn't exist
  Future<User> updateUserStatus(String userId, String status) async {
    final user = await getUser(userId);
    if (user == null) {
      throw ArgumentError('User with ID $userId not found');
    }

    final updatedUser = user.updateStatus(status);
    await updateUser(updatedUser);

    return updatedUser;
  }

  /// Deletes a user from the system
  ///
  /// [userId] The ID of the user to delete
  ///
  /// Throws [ArgumentError] if trying to delete a non-existent user
  Future<void> deleteUser(String userId) async {
    final user = await getUser(userId);
    if (user == null) {
      throw ArgumentError('User with ID $userId not found');
    }

    _userCache.remove(userId);

    if (!user.isGuest) {
      await LocalDatabaseService.instance.deleteUser(userId);
    }

    _userEventController.add(MapEntry(UserEvent.deleted, user));
  }

  /// Gets a cached user from memory (fast access)
  ///
  /// [userId] The ID of the user to retrieve
  ///
  /// Returns the cached User object if available, null otherwise
  User? getCachedUser(String userId) => _userCache[userId];

  /// Preloads users into cache for efficient access
  ///
  /// [userIds] List of user IDs to preload
  Future<void> preloadUsers(List<String> userIds) async {
    for (final userId in userIds) {
      if (!_userCache.containsKey(userId)) {
        final user = await LocalDatabaseService.instance.getUser(userId);
        if (user != null) {
          _userCache[userId] = user;
        }
      }
    }
  }

  /// Stream of user events (created, updated, deleted, presence changes)
  Stream<MapEntry<UserEvent, User>> get userEvents =>
      _userEventController.stream;

  /// Clears the user cache
  ///
  /// Useful for memory management or when switching contexts
  void clearCache() {
    _userCache.clear();
  }

  /// Gets the number of cached users
  int get cachedUserCount => _userCache.length;

  /// Checks if a user is cached
  bool isUserCached(String userId) => _userCache.containsKey(userId);

  /// Disposes of the user service and closes streams
  ///
  /// Call this when the service is no longer needed to prevent memory leaks
  void dispose() {
    _userEventController.close();
    _userCache.clear();
    _instance = null;
  }
}

/// Enum for user-related events
enum UserEvent {
  created,
  updated,
  deleted,
  presenceChanged,
}
