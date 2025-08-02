import 'package:chat_app_package/src/src.dart';

/// Service class for managing users in the chat application.
class UserService {
  UserService._();
  static UserService? _instance;

  /// Gets the singleton instance of the user service.
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
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

    await SyncService.instance.saveUser(user);

    return user;
  }

  /// Watches all users from the local database
  ///
  /// Returns a stream of all User objects that updates in real-time
  Stream<List<User>> watchAllUsers() {
    return LocalDatabaseService.instance.watchAllUsers();
  }

  /// Deletes a user from the system
  ///
  /// [userId] The ID of the user to delete
  Future<void> deleteUser(String userId) async {
    await SyncService.instance.deleteUser(userId);
  }

  Future<User?> getUser(String senderId) {
    return LocalDatabaseService.instance.getUser(senderId);
  }
}
