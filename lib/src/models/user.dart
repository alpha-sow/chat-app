import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Immutable model representing a user in the chat application.
/// 
/// Contains user profile information, online status, and metadata.
/// Supports presence tracking and extensible metadata for future features.
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? email,
    String? avatarUrl,
    @Default(true) bool isOnline,
    @Default('') String status,
    DateTime? lastSeen,
    @Default({}) Map<String, dynamic> metadata,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  const User._();

  // Factory constructors for common user creation patterns
  factory User.create({
    String? id,
    required String name,
    String? email,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? _generateUserId(),
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      isOnline: true,
    );
  }

  factory User.guest(String name) {
    return User(
      id: 'guest_${_generateUserId()}',
      name: name,
      isOnline: true,
      status: 'Guest User',
    );
  }

  // Helper methods
  String get displayName => name.isNotEmpty ? name : 'User ${id.substring(0, 8)}';
  
  bool get isGuest => id.startsWith('guest_');
  
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  User setOnline() => copyWith(isOnline: true, lastSeen: DateTime.now());
  
  User setOffline() => copyWith(isOnline: false, lastSeen: DateTime.now());
  
  User updateStatus(String newStatus) => copyWith(status: newStatus);

  static String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}