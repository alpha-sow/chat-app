import 'package:chat_app_package/src/src.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
sealed class Message with _$Message {
  const factory Message({
    required String id,
    required String senderId,
    required String content,
    @Default(MessageType.text) MessageType type,
    required DateTime timestamp,
    @Default(false) bool edited,
    DateTime? editedAt,
    @Default(<String, Set<String>>{}) Map<String, Set<String>> reactions,
    @Default(<Message>[]) List<Message> replies,
    Set<String>? readBy,
    String? replyToId,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  // Custom method to create a new message with generated ID
  factory Message.create({
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
  }) {
    return Message(
      id: _generateMessageId(),
      senderId: senderId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      replyToId: replyToId,
    );
  }

  static String _generateMessageId() {
    const uuid = Uuid();
    return uuid.v4();
  }
}
