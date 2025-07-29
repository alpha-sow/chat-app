import 'package:chat_app_package/src/src.dart';
import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class IsarMessage {
  Id id = Isar.autoIncrement;

  @Index()
  String? messageId;

  @Index()
  String? discussionId;

  @Index()
  String? senderId;

  String? content;

  @Enumerated(EnumType.name)
  MessageType type = MessageType.text;

  @Index()
  DateTime? timestamp;

  bool edited = false;
  DateTime? editedAt;

  String? reactionsJson;

  String? replyToId;

  List<String> replyIds = [];

  List<String> readByIds = [];

  static IsarMessage fromMessage(Message message, String discussionId) {
    return IsarMessage()
      ..messageId = message.id
      ..discussionId = discussionId
      ..senderId = message.senderId
      ..content = message.content
      ..type = message.type
      ..timestamp = message.timestamp
      ..edited = message.edited
      ..editedAt = message.editedAt
      ..reactionsJson = _encodeReactions(message.reactions)
      ..replyToId = message.replyToId
      ..replyIds = message.replies.map((r) => r.id).toList()
      ..readByIds = message.readBy?.toList() ?? [];
  }

  Message toMessage() {
    if (messageId == null || messageId!.isEmpty) {
      throw StateError('Message ID cannot be null or empty');
    }
    if (senderId == null || senderId!.isEmpty) {
      throw StateError('Sender ID cannot be null or empty');
    }
    if (content == null) {
      throw StateError('Message content cannot be null');
    }
    if (timestamp == null) {
      throw StateError('Message timestamp cannot be null');
    }

    return Message(
      id: messageId!,
      senderId: senderId!,
      content: content!,
      type: type,
      timestamp: timestamp!,
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
    return jsonMap.toString();
  }

  static Map<String, Set<String>> _decodeReactions(String? reactionsJson) {
    if (reactionsJson == null || reactionsJson.isEmpty) return {};

    return {};
  }
}

@collection
class IsarDiscussion {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? discussionId;

  String? title;

  List<String> participantIds = [];

  @Index()
  DateTime? createdAt;

  @Index()
  DateTime? lastActivity;

  bool isActive = true;

  String? metadataJson;

  static IsarDiscussion fromDiscussion(Discussion state) {
    return IsarDiscussion()
      ..discussionId = state.id
      ..title = state.title
      ..participantIds = state.participants.toList()
      ..createdAt = state.createdAt
      ..lastActivity = state.lastActivity
      ..isActive = state.isActive;
  }

  Discussion toDiscussion() {
    return Discussion(
      id: discussionId!,
      title: title!,
      participants: participantIds.toSet(),
      messages: [],
      createdAt: createdAt!,
      lastActivity: lastActivity!,
      isActive: isActive,
    );
  }
}

@collection
class IsarUser {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? userId;

  String? name;
  String? email;
  String? phoneNumber;
  String? avatarUrl;

  bool isOnline = true;
  String status = '';

  @Index()
  DateTime? lastSeen;

  String? metadataJson;

  static IsarUser fromUser(User user) {
    return IsarUser()
      ..userId = user.id
      ..name = user.name
      ..email = user.email
      ..phoneNumber = user.phoneNumber
      ..avatarUrl = user.avatarUrl
      ..isOnline = user.isOnline
      ..status = user.status
      ..lastSeen = user.lastSeen;
  }

  User toUser() {
    return User(
      id: userId!,
      name: name!,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      isOnline: isOnline,
      status: status,
      lastSeen: lastSeen,
    );
  }
}
