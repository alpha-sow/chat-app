// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  bool get edited => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  Map<String, Set<String>> get reactions => throw _privateConstructorUsedError;
  List<Message> get replies => throw _privateConstructorUsedError;
  Set<String>? get readBy => throw _privateConstructorUsedError;
  String? get replyToId => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String senderId,
      String content,
      DateTime timestamp,
      MessageType type,
      bool edited,
      DateTime? editedAt,
      Map<String, Set<String>> reactions,
      List<Message> replies,
      Set<String>? readBy,
      String? replyToId});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? content = null,
    Object? timestamp = null,
    Object? type = null,
    Object? edited = null,
    Object? editedAt = freezed,
    Object? reactions = null,
    Object? replies = null,
    Object? readBy = freezed,
    Object? replyToId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      edited: null == edited
          ? _value.edited
          : edited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as Map<String, Set<String>>,
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Message>,
      readBy: freezed == readBy
          ? _value.readBy
          : readBy // ignore: cast_nullable_to_non_nullable
              as Set<String>?,
      replyToId: freezed == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String senderId,
      String content,
      DateTime timestamp,
      MessageType type,
      bool edited,
      DateTime? editedAt,
      Map<String, Set<String>> reactions,
      List<Message> replies,
      Set<String>? readBy,
      String? replyToId});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? content = null,
    Object? timestamp = null,
    Object? type = null,
    Object? edited = null,
    Object? editedAt = freezed,
    Object? reactions = null,
    Object? replies = null,
    Object? readBy = freezed,
    Object? replyToId = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      edited: null == edited
          ? _value.edited
          : edited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reactions: null == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as Map<String, Set<String>>,
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Message>,
      readBy: freezed == readBy
          ? _value._readBy
          : readBy // ignore: cast_nullable_to_non_nullable
              as Set<String>?,
      replyToId: freezed == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.senderId,
      required this.content,
      required this.timestamp,
      this.type = MessageType.text,
      this.edited = false,
      this.editedAt,
      final Map<String, Set<String>> reactions = const <String, Set<String>>{},
      final List<Message> replies = const <Message>[],
      final Set<String>? readBy,
      this.replyToId})
      : _reactions = reactions,
        _replies = replies,
        _readBy = readBy;

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String content;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final MessageType type;
  @override
  @JsonKey()
  final bool edited;
  @override
  final DateTime? editedAt;
  final Map<String, Set<String>> _reactions;
  @override
  @JsonKey()
  Map<String, Set<String>> get reactions {
    if (_reactions is EqualUnmodifiableMapView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reactions);
  }

  final List<Message> _replies;
  @override
  @JsonKey()
  List<Message> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  final Set<String>? _readBy;
  @override
  Set<String>? get readBy {
    final value = _readBy;
    if (value == null) return null;
    if (_readBy is EqualUnmodifiableSetView) return _readBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(value);
  }

  @override
  final String? replyToId;

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, content: $content, timestamp: $timestamp, type: $type, edited: $edited, editedAt: $editedAt, reactions: $reactions, replies: $replies, readBy: $readBy, replyToId: $replyToId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.edited, edited) || other.edited == edited) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            const DeepCollectionEquality().equals(other._readBy, _readBy) &&
            (identical(other.replyToId, replyToId) ||
                other.replyToId == replyToId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      senderId,
      content,
      timestamp,
      type,
      edited,
      editedAt,
      const DeepCollectionEquality().hash(_reactions),
      const DeepCollectionEquality().hash(_replies),
      const DeepCollectionEquality().hash(_readBy),
      replyToId);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String senderId,
      required final String content,
      required final DateTime timestamp,
      final MessageType type,
      final bool edited,
      final DateTime? editedAt,
      final Map<String, Set<String>> reactions,
      final List<Message> replies,
      final Set<String>? readBy,
      final String? replyToId}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get content;
  @override
  DateTime get timestamp;
  @override
  MessageType get type;
  @override
  bool get edited;
  @override
  DateTime? get editedAt;
  @override
  Map<String, Set<String>> get reactions;
  @override
  List<Message> get replies;
  @override
  Set<String>? get readBy;
  @override
  String? get replyToId;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
