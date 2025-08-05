import 'dart:convert';

import 'package:dayder_chat/src/src.dart';
import 'package:hive/hive.dart';

part 'hive_models.g.dart';

@HiveType(typeId: 0)
class HiveMessage extends HiveObject {
  HiveMessage({
    required this.messageId,
    required this.discussionId,
    required this.senderId,
    required this.content,
    required this.typeIndex,
    required this.timestamp,
    this.edited = false,
    this.editedAt,
    this.reactionsJson,
    this.replyToId,
    this.replyIds = const [],
    this.readByIds = const [],
  });

  factory HiveMessage.fromMessage(Message message, String discussionId) {
    return HiveMessage(
      messageId: message.id,
      discussionId: discussionId,
      senderId: message.senderId,
      content: message.content,
      typeIndex: message.type.index,
      timestamp: message.timestamp,
      edited: message.edited,
      editedAt: message.editedAt,
      reactionsJson: _encodeReactions(message.reactions),
      replyToId: message.replyToId,
      replyIds: message.replies.map((Message r) => r.id).toList(),
      readByIds: message.readBy?.toList() ?? [],
    );
  }

  @HiveField(0)
  String messageId;

  @HiveField(1)
  String discussionId;

  @HiveField(2)
  String senderId;

  @HiveField(3)
  String content;

  @HiveField(4)
  int typeIndex;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  bool edited;

  @HiveField(7)
  DateTime? editedAt;

  @HiveField(8)
  String? reactionsJson;

  @HiveField(9)
  String? replyToId;

  @HiveField(10)
  List<String> replyIds;

  @HiveField(11)
  List<String> readByIds;

  Message toMessage() {
    return Message(
      id: messageId,
      senderId: senderId,
      content: content,
      type: MessageType.values[typeIndex],
      timestamp: timestamp,
      edited: edited,
      editedAt: editedAt,
      reactions: _decodeReactions(reactionsJson),
      replyToId: replyToId,
      replies: [],
      readBy: readByIds.isNotEmpty ? readByIds.toSet() : null,
    );
  }

  static String? _encodeReactions(Map<String, Set<String>> reactions) {
    if (reactions.isEmpty) return null;

    final jsonMap = reactions.map(
      (key, value) => MapEntry(key, value.toList()),
    );
    return jsonEncode(jsonMap);
  }

  static Map<String, Set<String>> _decodeReactions(String? reactionsJson) {
    if (reactionsJson == null || reactionsJson.isEmpty) return {};

    try {
      final decoded = jsonDecode(reactionsJson) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          Set<String>.from(value as List),
        ),
      );
    } on Exception {
      return {};
    }
  }
}

@HiveType(typeId: 1)
class HiveDiscussion extends HiveObject {
  HiveDiscussion({
    required this.discussionId,
    required this.title,
    required this.createdAt,
    required this.lastActivity,
    this.participantIds = const [],
    this.isActive = true,
    this.lastMessageJson,
    this.typeIndex = 0,
  });

  factory HiveDiscussion.fromDiscussion(Discussion discussion) {
    return HiveDiscussion(
      discussionId: discussion.id,
      title: discussion.title,
      participantIds: discussion.participants.toList(),
      createdAt: discussion.createdAt,
      lastActivity: discussion.lastActivity,
      isActive: discussion.isActive,
      lastMessageJson: _encodeMessage(discussion.lastMessage),
      typeIndex: discussion.type.index,
    );
  }

  @HiveField(0)
  String discussionId;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<String> participantIds;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime lastActivity;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  String? lastMessageJson;

  @HiveField(7)
  int typeIndex;

  Discussion toDiscussion() {
    return Discussion(
      id: discussionId,
      title: title,
      participants: participantIds.toSet(),
      createdAt: createdAt,
      lastActivity: lastActivity,
      lastMessage: _decodeMessage(lastMessageJson),
      isActive: isActive,
      type: DiscussionType.values[typeIndex],
    );
  }

  static String? _encodeMessage(Message? message) {
    if (message == null) return null;
    return jsonEncode(message.toJson());
  }

  static Message? _decodeMessage(String? messageJson) {
    if (messageJson == null || messageJson.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(messageJson);
      if (decoded is Map<String, dynamic>) {
        return Message.fromJson(decoded);
      }
      return null;
    } on Exception {
      return null;
    }
  }
}

@HiveType(typeId: 2)
class HiveUser extends HiveObject {
  HiveUser({
    required this.userId,
    required this.name,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.isOnline = true,
    this.status = '',
    this.lastSeen,
    this.metadataJson,
  });

  factory HiveUser.fromUser(User user) {
    return HiveUser(
      userId: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      isOnline: user.isOnline,
      status: user.status,
      lastSeen: user.lastSeen,
      metadataJson: user.metadata.isNotEmpty ? jsonEncode(user.metadata) : null,
    );
  }

  @HiveField(0)
  String userId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? phoneNumber;

  @HiveField(4)
  String? avatarUrl;

  @HiveField(5)
  bool isOnline;

  @HiveField(6)
  String status;

  @HiveField(7)
  DateTime? lastSeen;

  @HiveField(8)
  String? metadataJson;

  User toUser() {
    return User(
      id: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      isOnline: isOnline,
      status: status,
      lastSeen: lastSeen,
      metadata: _decodeMetadata(metadataJson),
    );
  }

  static Map<String, dynamic> _decodeMetadata(String? metadataJson) {
    if (metadataJson == null || metadataJson.isEmpty) return {};

    try {
      final decoded = jsonDecode(metadataJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } on Exception {
      return {};
    }
  }
}
