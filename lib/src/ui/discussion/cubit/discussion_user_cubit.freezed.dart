// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_user_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DiscussionUserState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(User user) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(User user)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(User user)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiscussionUserStateLoading value) loading,
    required TResult Function(DiscussionUserStateLoaded value) loaded,
    required TResult Function(DiscussionUserStateError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionUserStateLoading value)? loading,
    TResult? Function(DiscussionUserStateLoaded value)? loaded,
    TResult? Function(DiscussionUserStateError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionUserStateLoading value)? loading,
    TResult Function(DiscussionUserStateLoaded value)? loaded,
    TResult Function(DiscussionUserStateError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionUserStateCopyWith<$Res> {
  factory $DiscussionUserStateCopyWith(
    DiscussionUserState value,
    $Res Function(DiscussionUserState) then,
  ) = _$DiscussionUserStateCopyWithImpl<$Res, DiscussionUserState>;
}

/// @nodoc
class _$DiscussionUserStateCopyWithImpl<$Res, $Val extends DiscussionUserState>
    implements $DiscussionUserStateCopyWith<$Res> {
  _$DiscussionUserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DiscussionUserStateLoadingImplCopyWith<$Res> {
  factory _$$DiscussionUserStateLoadingImplCopyWith(
    _$DiscussionUserStateLoadingImpl value,
    $Res Function(_$DiscussionUserStateLoadingImpl) then,
  ) = __$$DiscussionUserStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DiscussionUserStateLoadingImplCopyWithImpl<$Res>
    extends
        _$DiscussionUserStateCopyWithImpl<
          $Res,
          _$DiscussionUserStateLoadingImpl
        >
    implements _$$DiscussionUserStateLoadingImplCopyWith<$Res> {
  __$$DiscussionUserStateLoadingImplCopyWithImpl(
    _$DiscussionUserStateLoadingImpl _value,
    $Res Function(_$DiscussionUserStateLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DiscussionUserStateLoadingImpl implements DiscussionUserStateLoading {
  const _$DiscussionUserStateLoadingImpl();

  @override
  String toString() {
    return 'DiscussionUserState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionUserStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(User user) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(User user)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(User user)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiscussionUserStateLoading value) loading,
    required TResult Function(DiscussionUserStateLoaded value) loaded,
    required TResult Function(DiscussionUserStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionUserStateLoading value)? loading,
    TResult? Function(DiscussionUserStateLoaded value)? loaded,
    TResult? Function(DiscussionUserStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionUserStateLoading value)? loading,
    TResult Function(DiscussionUserStateLoaded value)? loaded,
    TResult Function(DiscussionUserStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class DiscussionUserStateLoading implements DiscussionUserState {
  const factory DiscussionUserStateLoading() = _$DiscussionUserStateLoadingImpl;
}

/// @nodoc
abstract class _$$DiscussionUserStateLoadedImplCopyWith<$Res> {
  factory _$$DiscussionUserStateLoadedImplCopyWith(
    _$DiscussionUserStateLoadedImpl value,
    $Res Function(_$DiscussionUserStateLoadedImpl) then,
  ) = __$$DiscussionUserStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({User user});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$DiscussionUserStateLoadedImplCopyWithImpl<$Res>
    extends
        _$DiscussionUserStateCopyWithImpl<$Res, _$DiscussionUserStateLoadedImpl>
    implements _$$DiscussionUserStateLoadedImplCopyWith<$Res> {
  __$$DiscussionUserStateLoadedImplCopyWithImpl(
    _$DiscussionUserStateLoadedImpl _value,
    $Res Function(_$DiscussionUserStateLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null}) {
    return _then(
      _$DiscussionUserStateLoadedImpl(
        null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
      ),
    );
  }

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$DiscussionUserStateLoadedImpl implements DiscussionUserStateLoaded {
  const _$DiscussionUserStateLoadedImpl(this.user);

  @override
  final User user;

  @override
  String toString() {
    return 'DiscussionUserState.loaded(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionUserStateLoadedImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionUserStateLoadedImplCopyWith<_$DiscussionUserStateLoadedImpl>
  get copyWith =>
      __$$DiscussionUserStateLoadedImplCopyWithImpl<
        _$DiscussionUserStateLoadedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(User user) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(User user)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(User user)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiscussionUserStateLoading value) loading,
    required TResult Function(DiscussionUserStateLoaded value) loaded,
    required TResult Function(DiscussionUserStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionUserStateLoading value)? loading,
    TResult? Function(DiscussionUserStateLoaded value)? loaded,
    TResult? Function(DiscussionUserStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionUserStateLoading value)? loading,
    TResult Function(DiscussionUserStateLoaded value)? loaded,
    TResult Function(DiscussionUserStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class DiscussionUserStateLoaded implements DiscussionUserState {
  const factory DiscussionUserStateLoaded(final User user) =
      _$DiscussionUserStateLoadedImpl;

  User get user;

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionUserStateLoadedImplCopyWith<_$DiscussionUserStateLoadedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DiscussionUserStateErrorImplCopyWith<$Res> {
  factory _$$DiscussionUserStateErrorImplCopyWith(
    _$DiscussionUserStateErrorImpl value,
    $Res Function(_$DiscussionUserStateErrorImpl) then,
  ) = __$$DiscussionUserStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$DiscussionUserStateErrorImplCopyWithImpl<$Res>
    extends
        _$DiscussionUserStateCopyWithImpl<$Res, _$DiscussionUserStateErrorImpl>
    implements _$$DiscussionUserStateErrorImplCopyWith<$Res> {
  __$$DiscussionUserStateErrorImplCopyWithImpl(
    _$DiscussionUserStateErrorImpl _value,
    $Res Function(_$DiscussionUserStateErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$DiscussionUserStateErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DiscussionUserStateErrorImpl implements DiscussionUserStateError {
  const _$DiscussionUserStateErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'DiscussionUserState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionUserStateErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionUserStateErrorImplCopyWith<_$DiscussionUserStateErrorImpl>
  get copyWith =>
      __$$DiscussionUserStateErrorImplCopyWithImpl<
        _$DiscussionUserStateErrorImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(User user) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(User user)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(User user)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiscussionUserStateLoading value) loading,
    required TResult Function(DiscussionUserStateLoaded value) loaded,
    required TResult Function(DiscussionUserStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionUserStateLoading value)? loading,
    TResult? Function(DiscussionUserStateLoaded value)? loaded,
    TResult? Function(DiscussionUserStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionUserStateLoading value)? loading,
    TResult Function(DiscussionUserStateLoaded value)? loaded,
    TResult Function(DiscussionUserStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class DiscussionUserStateError implements DiscussionUserState {
  const factory DiscussionUserStateError(final String message) =
      _$DiscussionUserStateErrorImpl;

  String get message;

  /// Create a copy of DiscussionUserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionUserStateErrorImplCopyWith<_$DiscussionUserStateErrorImpl>
  get copyWith => throw _privateConstructorUsedError;
}
