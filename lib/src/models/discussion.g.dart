// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscussionImpl _$$DiscussionImplFromJson(Map<String, dynamic> json) =>
    _$DiscussionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      type: $enumDecodeNullable(_$DiscussionTypeEnumMap, json['type']) ??
          DiscussionType.direct,
    );

Map<String, dynamic> _$$DiscussionImplToJson(_$DiscussionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'participants': instance.participants.toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActivity': instance.lastActivity.toIso8601String(),
      'lastMessage': instance.lastMessage?.toJson(),
      'isActive': instance.isActive,
      'type': _$DiscussionTypeEnumMap[instance.type]!,
    };

const _$DiscussionTypeEnumMap = {
  DiscussionType.direct: 'direct',
  DiscussionType.group: 'group',
  DiscussionType.channel: 'channel',
  DiscussionType.temporary: 'temporary',
};
