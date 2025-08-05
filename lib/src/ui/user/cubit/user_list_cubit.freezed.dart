// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<User> data) loaded,
    required TResult Function(Exception e) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<User> data)? loaded,
    TResult? Function(Exception e)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<User> data)? loaded,
    TResult Function(Exception e)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserListStateLoading value) loading,
    required TResult Function(UserListStateLoaded value) loaded,
    required TResult Function(UserListStateError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserListStateLoading value)? loading,
    TResult? Function(UserListStateLoaded value)? loaded,
    TResult? Function(UserListStateError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserListStateLoading value)? loading,
    TResult Function(UserListStateLoaded value)? loaded,
    TResult Function(UserListStateError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserListStateCopyWith<$Res> {
  factory $UserListStateCopyWith(
    UserListState value,
    $Res Function(UserListState) then,
  ) = _$UserListStateCopyWithImpl<$Res, UserListState>;
}

/// @nodoc
class _$UserListStateCopyWithImpl<$Res, $Val extends UserListState>
    implements $UserListStateCopyWith<$Res> {
  _$UserListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$UserListStateLoadingImplCopyWith<$Res> {
  factory _$$UserListStateLoadingImplCopyWith(
    _$UserListStateLoadingImpl value,
    $Res Function(_$UserListStateLoadingImpl) then,
  ) = __$$UserListStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UserListStateLoadingImplCopyWithImpl<$Res>
    extends _$UserListStateCopyWithImpl<$Res, _$UserListStateLoadingImpl>
    implements _$$UserListStateLoadingImplCopyWith<$Res> {
  __$$UserListStateLoadingImplCopyWithImpl(
    _$UserListStateLoadingImpl _value,
    $Res Function(_$UserListStateLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UserListStateLoadingImpl implements UserListStateLoading {
  const _$UserListStateLoadingImpl();

  @override
  String toString() {
    return 'UserListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserListStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<User> data) loaded,
    required TResult Function(Exception e) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<User> data)? loaded,
    TResult? Function(Exception e)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<User> data)? loaded,
    TResult Function(Exception e)? error,
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
    required TResult Function(UserListStateLoading value) loading,
    required TResult Function(UserListStateLoaded value) loaded,
    required TResult Function(UserListStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserListStateLoading value)? loading,
    TResult? Function(UserListStateLoaded value)? loaded,
    TResult? Function(UserListStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserListStateLoading value)? loading,
    TResult Function(UserListStateLoaded value)? loaded,
    TResult Function(UserListStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class UserListStateLoading implements UserListState {
  const factory UserListStateLoading() = _$UserListStateLoadingImpl;
}

/// @nodoc
abstract class _$$UserListStateLoadedImplCopyWith<$Res> {
  factory _$$UserListStateLoadedImplCopyWith(
    _$UserListStateLoadedImpl value,
    $Res Function(_$UserListStateLoadedImpl) then,
  ) = __$$UserListStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<User> data});
}

/// @nodoc
class __$$UserListStateLoadedImplCopyWithImpl<$Res>
    extends _$UserListStateCopyWithImpl<$Res, _$UserListStateLoadedImpl>
    implements _$$UserListStateLoadedImplCopyWith<$Res> {
  __$$UserListStateLoadedImplCopyWithImpl(
    _$UserListStateLoadedImpl _value,
    $Res Function(_$UserListStateLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$UserListStateLoadedImpl(
        null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<User>,
      ),
    );
  }
}

/// @nodoc

class _$UserListStateLoadedImpl implements UserListStateLoaded {
  const _$UserListStateLoadedImpl(final List<User> data) : _data = data;

  final List<User> _data;
  @override
  List<User> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'UserListState.loaded(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserListStateLoadedImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserListStateLoadedImplCopyWith<_$UserListStateLoadedImpl> get copyWith =>
      __$$UserListStateLoadedImplCopyWithImpl<_$UserListStateLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<User> data) loaded,
    required TResult Function(Exception e) error,
  }) {
    return loaded(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<User> data)? loaded,
    TResult? Function(Exception e)? error,
  }) {
    return loaded?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<User> data)? loaded,
    TResult Function(Exception e)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserListStateLoading value) loading,
    required TResult Function(UserListStateLoaded value) loaded,
    required TResult Function(UserListStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserListStateLoading value)? loading,
    TResult? Function(UserListStateLoaded value)? loaded,
    TResult? Function(UserListStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserListStateLoading value)? loading,
    TResult Function(UserListStateLoaded value)? loaded,
    TResult Function(UserListStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class UserListStateLoaded implements UserListState {
  const factory UserListStateLoaded(final List<User> data) =
      _$UserListStateLoadedImpl;

  List<User> get data;

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserListStateLoadedImplCopyWith<_$UserListStateLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UserListStateErrorImplCopyWith<$Res> {
  factory _$$UserListStateErrorImplCopyWith(
    _$UserListStateErrorImpl value,
    $Res Function(_$UserListStateErrorImpl) then,
  ) = __$$UserListStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Exception e});
}

/// @nodoc
class __$$UserListStateErrorImplCopyWithImpl<$Res>
    extends _$UserListStateCopyWithImpl<$Res, _$UserListStateErrorImpl>
    implements _$$UserListStateErrorImplCopyWith<$Res> {
  __$$UserListStateErrorImplCopyWithImpl(
    _$UserListStateErrorImpl _value,
    $Res Function(_$UserListStateErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? e = null}) {
    return _then(
      _$UserListStateErrorImpl(
        null == e
            ? _value.e
            : e // ignore: cast_nullable_to_non_nullable
                  as Exception,
      ),
    );
  }
}

/// @nodoc

class _$UserListStateErrorImpl implements UserListStateError {
  const _$UserListStateErrorImpl(this.e);

  @override
  final Exception e;

  @override
  String toString() {
    return 'UserListState.error(e: $e)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserListStateErrorImpl &&
            (identical(other.e, e) || other.e == e));
  }

  @override
  int get hashCode => Object.hash(runtimeType, e);

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserListStateErrorImplCopyWith<_$UserListStateErrorImpl> get copyWith =>
      __$$UserListStateErrorImplCopyWithImpl<_$UserListStateErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<User> data) loaded,
    required TResult Function(Exception e) error,
  }) {
    return error(e);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<User> data)? loaded,
    TResult? Function(Exception e)? error,
  }) {
    return error?.call(e);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<User> data)? loaded,
    TResult Function(Exception e)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(e);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserListStateLoading value) loading,
    required TResult Function(UserListStateLoaded value) loaded,
    required TResult Function(UserListStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserListStateLoading value)? loading,
    TResult? Function(UserListStateLoaded value)? loaded,
    TResult? Function(UserListStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserListStateLoading value)? loading,
    TResult Function(UserListStateLoaded value)? loaded,
    TResult Function(UserListStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class UserListStateError implements UserListState {
  const factory UserListStateError(final Exception e) =
      _$UserListStateErrorImpl;

  Exception get e;

  /// Create a copy of UserListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserListStateErrorImplCopyWith<_$UserListStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
