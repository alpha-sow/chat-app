import 'package:isar/isar.dart';
import 'package:tchat_app/src/src.dart';

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
  
  // Store reactions as JSON string since Isar doesn't support nested maps
  String? reactionsJson;
  
  // Store reply message IDs as list
  List<String> replyIds = [];
  
  // Store read by user IDs
  List<String> readByIds = [];
  
  // Convert from Message model
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
      ..replyIds = message.replies.map((r) => r.id).toList()
      ..readByIds = message.readBy?.toList() ?? [];
  }
  
  // Convert to Message model
  Message toMessage() {
    return Message(
      id: messageId!,
      senderId: senderId!,
      content: content!,
      type: type,
      timestamp: timestamp!,
      edited: edited,
      editedAt: editedAt,
      reactions: _decodeReactions(reactionsJson),
      replies: [], // Replies would need separate query
      readBy: readByIds.isNotEmpty ? readByIds.toSet() : null,
    );
  }
  
  static String? _encodeReactions(Map<String, Set<String>> reactions) {
    if (reactions.isEmpty) return null;
    // Convert Set<String> to List<String> for JSON serialization
    final jsonMap = reactions.map((key, value) => MapEntry(key, value.toList()));
    return jsonMap.toString(); // Simple string encoding for now
  }
  
  static Map<String, Set<String>> _decodeReactions(String? reactionsJson) {
    if (reactionsJson == null || reactionsJson.isEmpty) return {};
    // This is a simplified decoder - in production you'd use proper JSON
    return {}; // Return empty for now, implement proper JSON parsing as needed
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
  
  // Metadata as JSON string
  String? metadataJson;
  
  // Convert from DiscussionState
  static IsarDiscussion fromDiscussionState(DiscussionState state) {
    return IsarDiscussion()
      ..discussionId = state.id
      ..title = state.title
      ..participantIds = state.participants.toList()
      ..createdAt = state.createdAt
      ..lastActivity = state.lastActivity
      ..isActive = state.isActive;
  }
  
  // Convert to DiscussionState (without messages, those are loaded separately)
  DiscussionState toDiscussionState() {
    return DiscussionState(
      id: discussionId!,
      title: title!,
      participants: participantIds.toSet(),
      messages: [], // Messages loaded separately
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
  String? avatarUrl;
  
  bool isOnline = true;
  String status = '';
  
  @Index()
  DateTime? lastSeen;
  
  // Metadata as JSON string
  String? metadataJson;
  
  // Convert from User model
  static IsarUser fromUser(User user) {
    return IsarUser()
      ..userId = user.id
      ..name = user.name
      ..email = user.email
      ..avatarUrl = user.avatarUrl
      ..isOnline = user.isOnline
      ..status = user.status
      ..lastSeen = user.lastSeen;
  }
  
  // Convert to User model
  User toUser() {
    return User(
      id: userId!,
      name: name!,
      email: email,
      avatarUrl: avatarUrl,
      isOnline: isOnline,
      status: status,
      lastSeen: lastSeen,
    );
  }
}