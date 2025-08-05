// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MessageListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<Message> messages) loaded,
    required TResult Function(Exception error) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<Message> messages)? loaded,
    TResult? Function(Exception error)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<Message> messages)? loaded,
    TResult Function(Exception error)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessageListStateLoaded value) loaded,
    required TResult Function(MessageListStateError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessageListStateLoaded value)? loaded,
    TResult? Function(MessageListStateError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessageListStateLoaded value)? loaded,
    TResult Function(MessageListStateError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageListStateCopyWith<$Res> {
  factory $MessageListStateCopyWith(
    MessageListState value,
    $Res Function(MessageListState) then,
  ) = _$MessageListStateCopyWithImpl<$Res, MessageListState>;
}

/// @nodoc
class _$MessageListStateCopyWithImpl<$Res, $Val extends MessageListState>
    implements $MessageListStateCopyWith<$Res> {
  _$MessageListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$MessageListStateLoadedImplCopyWith<$Res> {
  factory _$$MessageListStateLoadedImplCopyWith(
    _$MessageListStateLoadedImpl value,
    $Res Function(_$MessageListStateLoadedImpl) then,
  ) = __$$MessageListStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Message> messages});
}

/// @nodoc
class __$$MessageListStateLoadedImplCopyWithImpl<$Res>
    extends _$MessageListStateCopyWithImpl<$Res, _$MessageListStateLoadedImpl>
    implements _$$MessageListStateLoadedImplCopyWith<$Res> {
  __$$MessageListStateLoadedImplCopyWithImpl(
    _$MessageListStateLoadedImpl _value,
    $Res Function(_$MessageListStateLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? messages = null}) {
    return _then(
      _$MessageListStateLoadedImpl(
        null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<Message>,
      ),
    );
  }
}

/// @nodoc

class _$MessageListStateLoadedImpl implements MessageListStateLoaded {
  const _$MessageListStateLoadedImpl(final List<Message> messages)
    : _messages = messages;

  final List<Message> _messages;
  @override
  List<Message> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  String toString() {
    return 'MessageListState.loaded(messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageListStateLoadedImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_messages));

  /// Create a copy of MessageListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageListStateLoadedImplCopyWith<_$MessageListStateLoadedImpl>
  get copyWith =>
      __$$MessageListStateLoadedImplCopyWithImpl<_$MessageListStateLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<Message> messages) loaded,
    required TResult Function(Exception error) error,
  }) {
    return loaded(messages);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<Message> messages)? loaded,
    TResult? Function(Exception error)? error,
  }) {
    return loaded?.call(messages);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<Message> messages)? loaded,
    TResult Function(Exception error)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(messages);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessageListStateLoaded value) loaded,
    required TResult Function(MessageListStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessageListStateLoaded value)? loaded,
    TResult? Function(MessageListStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessageListStateLoaded value)? loaded,
    TResult Function(MessageListStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class MessageListStateLoaded implements MessageListState {
  const factory MessageListStateLoaded(final List<Message> messages) =
      _$MessageListStateLoadedImpl;

  List<Message> get messages;

  /// Create a copy of MessageListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageListStateLoadedImplCopyWith<_$MessageListStateLoadedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessageListStateErrorImplCopyWith<$Res> {
  factory _$$MessageListStateErrorImplCopyWith(
    _$MessageListStateErrorImpl value,
    $Res Function(_$MessageListStateErrorImpl) then,
  ) = __$$MessageListStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Exception error});
}

/// @nodoc
class __$$MessageListStateErrorImplCopyWithImpl<$Res>
    extends _$MessageListStateCopyWithImpl<$Res, _$MessageListStateErrorImpl>
    implements _$$MessageListStateErrorImplCopyWith<$Res> {
  __$$MessageListStateErrorImplCopyWithImpl(
    _$MessageListStateErrorImpl _value,
    $Res Function(_$MessageListStateErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? error = null}) {
    return _then(
      _$MessageListStateErrorImpl(
        null == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as Exception,
      ),
    );
  }
}

/// @nodoc

class _$MessageListStateErrorImpl implements MessageListStateError {
  const _$MessageListStateErrorImpl(this.error);

  @override
  final Exception error;

  @override
  String toString() {
    return 'MessageListState.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageListStateErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of MessageListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageListStateErrorImplCopyWith<_$MessageListStateErrorImpl>
  get copyWith =>
      __$$MessageListStateErrorImplCopyWithImpl<_$MessageListStateErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<Message> messages) loaded,
    required TResult Function(Exception error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<Message> messages)? loaded,
    TResult? Function(Exception error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<Message> messages)? loaded,
    TResult Function(Exception error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MessageListStateLoaded value) loaded,
    required TResult Function(MessageListStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MessageListStateLoaded value)? loaded,
    TResult? Function(MessageListStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MessageListStateLoaded value)? loaded,
    TResult Function(MessageListStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class MessageListStateError implements MessageListState {
  const factory MessageListStateError(final Exception error) =
      _$MessageListStateErrorImpl;

  Exception get error;

  /// Create a copy of MessageListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageListStateErrorImplCopyWith<_$MessageListStateErrorImpl>
  get copyWith => throw _privateConstructorUsedError;
}
