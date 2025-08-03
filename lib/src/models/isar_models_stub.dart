// Web stub for Isar models - provides empty implementations
// This file is used when building for web to avoid JavaScript integer limitations

import 'package:chat_app_package/src/src.dart';

class IsarMessage {
  String? messageId;
  String? discussionId;
  String? senderId;
  String? content;
  MessageType type = MessageType.text;
  DateTime? timestamp;
  bool edited = false;
  DateTime? editedAt;
  String? reactionsJson;
  String? replyToId;
  List<String> replyIds = [];
  List<String> readByIds = [];

  static IsarMessage fromMessage(Message message, String discussionId) {
    throw UnsupportedError('Isar not supported on web platform');
  }

  Message toMessage() {
    throw UnsupportedError('Isar not supported on web platform');
  }
}

class IsarDiscussion {
  String? discussionId;
  String? title;
  List<String> participantIds = [];
  DateTime? createdAt;
  DateTime? lastActivity;
  bool isActive = true;
  String? metadataJson;
  String? lastMessageJson;

  static IsarDiscussion fromDiscussion(Discussion state) {
    throw UnsupportedError('Isar not supported on web platform');
  }

  Discussion toDiscussion() {
    throw UnsupportedError('Isar not supported on web platform');
  }
}

class IsarUser {
  String? userId;
  String? name;
  String? email;
  String? phoneNumber;
  String? avatarUrl;
  bool isOnline = true;
  String status = '';
  DateTime? lastSeen;
  String? metadataJson;

  static IsarUser fromUser(User user) {
    throw UnsupportedError('Isar not supported on web platform');
  }

  User toUser() {
    throw UnsupportedError('Isar not supported on web platform');
  }
}
