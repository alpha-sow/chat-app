// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Discussion _$DiscussionFromJson(Map<String, dynamic> json) {
  return _Discussion.fromJson(json);
}

/// @nodoc
mixin _$Discussion {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  Set<String> get participants => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastActivity => throw _privateConstructorUsedError;
  Message? get lastMessage => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DiscussionType get type => throw _privateConstructorUsedError;

  /// Serializes this Discussion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionCopyWith<Discussion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionCopyWith<$Res> {
  factory $DiscussionCopyWith(
          Discussion value, $Res Function(Discussion) then) =
      _$DiscussionCopyWithImpl<$Res, Discussion>;
  @useResult
  $Res call(
      {String id,
      String title,
      Set<String> participants,
      DateTime createdAt,
      DateTime lastActivity,
      Message? lastMessage,
      bool isActive,
      DiscussionType type});

  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$DiscussionCopyWithImpl<$Res, $Val extends Discussion>
    implements $DiscussionCopyWith<$Res> {
  _$DiscussionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? participants = null,
    Object? createdAt = null,
    Object? lastActivity = null,
    Object? lastMessage = freezed,
    Object? isActive = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DiscussionType,
    ) as $Val);
  }

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiscussionImplCopyWith<$Res>
    implements $DiscussionCopyWith<$Res> {
  factory _$$DiscussionImplCopyWith(
          _$DiscussionImpl value, $Res Function(_$DiscussionImpl) then) =
      __$$DiscussionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      Set<String> participants,
      DateTime createdAt,
      DateTime lastActivity,
      Message? lastMessage,
      bool isActive,
      DiscussionType type});

  @override
  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$DiscussionImplCopyWithImpl<$Res>
    extends _$DiscussionCopyWithImpl<$Res, _$DiscussionImpl>
    implements _$$DiscussionImplCopyWith<$Res> {
  __$$DiscussionImplCopyWithImpl(
      _$DiscussionImpl _value, $Res Function(_$DiscussionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? participants = null,
    Object? createdAt = null,
    Object? lastActivity = null,
    Object? lastMessage = freezed,
    Object? isActive = null,
    Object? type = null,
  }) {
    return _then(_$DiscussionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DiscussionType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscussionImpl extends _Discussion {
  const _$DiscussionImpl(
      {required this.id,
      required this.title,
      required final Set<String> participants,
      required this.createdAt,
      required this.lastActivity,
      this.lastMessage,
      this.isActive = true,
      this.type = DiscussionType.direct})
      : _participants = participants,
        super._();

  factory _$DiscussionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscussionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  final Set<String> _participants;
  @override
  Set<String> get participants {
    if (_participants is EqualUnmodifiableSetView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_participants);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime lastActivity;
  @override
  final Message? lastMessage;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final DiscussionType type;

  @override
  String toString() {
    return 'Discussion(id: $id, title: $title, participants: $participants, createdAt: $createdAt, lastActivity: $lastActivity, lastMessage: $lastMessage, isActive: $isActive, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      const DeepCollectionEquality().hash(_participants),
      createdAt,
      lastActivity,
      lastMessage,
      isActive,
      type);

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionImplCopyWith<_$DiscussionImpl> get copyWith =>
      __$$DiscussionImplCopyWithImpl<_$DiscussionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscussionImplToJson(
      this,
    );
  }
}

abstract class _Discussion extends Discussion {
  const factory _Discussion(
      {required final String id,
      required final String title,
      required final Set<String> participants,
      required final DateTime createdAt,
      required final DateTime lastActivity,
      final Message? lastMessage,
      final bool isActive,
      final DiscussionType type}) = _$DiscussionImpl;
  const _Discussion._() : super._();

  factory _Discussion.fromJson(Map<String, dynamic> json) =
      _$DiscussionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  Set<String> get participants;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastActivity;
  @override
  Message? get lastMessage;
  @override
  bool get isActive;
  @override
  DiscussionType get type;

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionImplCopyWith<_$DiscussionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
