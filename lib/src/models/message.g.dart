// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      edited: json['edited'] as bool? ?? false,
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toSet()),
          ) ??
          const <String, Set<String>>{},
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Message>[],
      readBy:
          (json['readBy'] as List<dynamic>?)?.map((e) => e as String).toSet(),
      replyToId: json['replyToId'] as String?,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$MessageTypeEnumMap[instance.type]!,
      'edited': instance.edited,
      'editedAt': instance.editedAt?.toIso8601String(),
      'reactions': instance.reactions.map((k, e) => MapEntry(k, e.toList())),
      'replies': instance.replies.map((e) => e.toJson()).toList(),
      'readBy': instance.readBy?.toList(),
      'replyToId': instance.replyToId,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.file: 'file',
  MessageType.audio: 'audio',
  MessageType.video: 'video',
};
