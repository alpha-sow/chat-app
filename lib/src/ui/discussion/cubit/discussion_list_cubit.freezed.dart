// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DiscussionListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<Discussion> data) loaded,
    required TResult Function(Exception e) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<Discussion> data)? loaded,
    TResult? Function(Exception e)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<Discussion> data)? loaded,
    TResult Function(Exception e)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DiscussionListStateLoading value) loading,
    required TResult Function(DiscussionListStateLoaded value) loaded,
    required TResult Function(DiscussionListStateError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionListStateLoading value)? loading,
    TResult? Function(DiscussionListStateLoaded value)? loaded,
    TResult? Function(DiscussionListStateError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionListStateLoading value)? loading,
    TResult Function(DiscussionListStateLoaded value)? loaded,
    TResult Function(DiscussionListStateError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionListStateCopyWith<$Res> {
  factory $DiscussionListStateCopyWith(
    DiscussionListState value,
    $Res Function(DiscussionListState) then,
  ) = _$DiscussionListStateCopyWithImpl<$Res, DiscussionListState>;
}

/// @nodoc
class _$DiscussionListStateCopyWithImpl<$Res, $Val extends DiscussionListState>
    implements $DiscussionListStateCopyWith<$Res> {
  _$DiscussionListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DiscussionListStateLoadingImplCopyWith<$Res> {
  factory _$$DiscussionListStateLoadingImplCopyWith(
    _$DiscussionListStateLoadingImpl value,
    $Res Function(_$DiscussionListStateLoadingImpl) then,
  ) = __$$DiscussionListStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DiscussionListStateLoadingImplCopyWithImpl<$Res>
    extends
        _$DiscussionListStateCopyWithImpl<
          $Res,
          _$DiscussionListStateLoadingImpl
        >
    implements _$$DiscussionListStateLoadingImplCopyWith<$Res> {
  __$$DiscussionListStateLoadingImplCopyWithImpl(
    _$DiscussionListStateLoadingImpl _value,
    $Res Function(_$DiscussionListStateLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DiscussionListStateLoadingImpl implements DiscussionListStateLoading {
  const _$DiscussionListStateLoadingImpl();

  @override
  String toString() {
    return 'DiscussionListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionListStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<Discussion> data) loaded,
    required TResult Function(Exception e) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<Discussion> data)? loaded,
    TResult? Function(Exception e)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<Discussion> data)? loaded,
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
    required TResult Function(DiscussionListStateLoading value) loading,
    required TResult Function(DiscussionListStateLoaded value) loaded,
    required TResult Function(DiscussionListStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionListStateLoading value)? loading,
    TResult? Function(DiscussionListStateLoaded value)? loaded,
    TResult? Function(DiscussionListStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionListStateLoading value)? loading,
    TResult Function(DiscussionListStateLoaded value)? loaded,
    TResult Function(DiscussionListStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class DiscussionListStateLoading implements DiscussionListState {
  const factory DiscussionListStateLoading() = _$DiscussionListStateLoadingImpl;
}

/// @nodoc
abstract class _$$DiscussionListStateLoadedImplCopyWith<$Res> {
  factory _$$DiscussionListStateLoadedImplCopyWith(
    _$DiscussionListStateLoadedImpl value,
    $Res Function(_$DiscussionListStateLoadedImpl) then,
  ) = __$$DiscussionListStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Discussion> data});
}

/// @nodoc
class __$$DiscussionListStateLoadedImplCopyWithImpl<$Res>
    extends
        _$DiscussionListStateCopyWithImpl<$Res, _$DiscussionListStateLoadedImpl>
    implements _$$DiscussionListStateLoadedImplCopyWith<$Res> {
  __$$DiscussionListStateLoadedImplCopyWithImpl(
    _$DiscussionListStateLoadedImpl _value,
    $Res Function(_$DiscussionListStateLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$DiscussionListStateLoadedImpl(
        null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<Discussion>,
      ),
    );
  }
}

/// @nodoc

class _$DiscussionListStateLoadedImpl implements DiscussionListStateLoaded {
  const _$DiscussionListStateLoadedImpl(final List<Discussion> data)
    : _data = data;

  final List<Discussion> _data;
  @override
  List<Discussion> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'DiscussionListState.loaded(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionListStateLoadedImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionListStateLoadedImplCopyWith<_$DiscussionListStateLoadedImpl>
  get copyWith =>
      __$$DiscussionListStateLoadedImplCopyWithImpl<
        _$DiscussionListStateLoadedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<Discussion> data) loaded,
    required TResult Function(Exception e) error,
  }) {
    return loaded(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<Discussion> data)? loaded,
    TResult? Function(Exception e)? error,
  }) {
    return loaded?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<Discussion> data)? loaded,
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
    required TResult Function(DiscussionListStateLoading value) loading,
    required TResult Function(DiscussionListStateLoaded value) loaded,
    required TResult Function(DiscussionListStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionListStateLoading value)? loading,
    TResult? Function(DiscussionListStateLoaded value)? loaded,
    TResult? Function(DiscussionListStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionListStateLoading value)? loading,
    TResult Function(DiscussionListStateLoaded value)? loaded,
    TResult Function(DiscussionListStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class DiscussionListStateLoaded implements DiscussionListState {
  const factory DiscussionListStateLoaded(final List<Discussion> data) =
      _$DiscussionListStateLoadedImpl;

  List<Discussion> get data;

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionListStateLoadedImplCopyWith<_$DiscussionListStateLoadedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DiscussionListStateErrorImplCopyWith<$Res> {
  factory _$$DiscussionListStateErrorImplCopyWith(
    _$DiscussionListStateErrorImpl value,
    $Res Function(_$DiscussionListStateErrorImpl) then,
  ) = __$$DiscussionListStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Exception e});
}

/// @nodoc
class __$$DiscussionListStateErrorImplCopyWithImpl<$Res>
    extends
        _$DiscussionListStateCopyWithImpl<$Res, _$DiscussionListStateErrorImpl>
    implements _$$DiscussionListStateErrorImplCopyWith<$Res> {
  __$$DiscussionListStateErrorImplCopyWithImpl(
    _$DiscussionListStateErrorImpl _value,
    $Res Function(_$DiscussionListStateErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? e = null}) {
    return _then(
      _$DiscussionListStateErrorImpl(
        null == e
            ? _value.e
            : e // ignore: cast_nullable_to_non_nullable
                  as Exception,
      ),
    );
  }
}

/// @nodoc

class _$DiscussionListStateErrorImpl implements DiscussionListStateError {
  const _$DiscussionListStateErrorImpl(this.e);

  @override
  final Exception e;

  @override
  String toString() {
    return 'DiscussionListState.error(e: $e)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionListStateErrorImpl &&
            (identical(other.e, e) || other.e == e));
  }

  @override
  int get hashCode => Object.hash(runtimeType, e);

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionListStateErrorImplCopyWith<_$DiscussionListStateErrorImpl>
  get copyWith =>
      __$$DiscussionListStateErrorImplCopyWithImpl<
        _$DiscussionListStateErrorImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<Discussion> data) loaded,
    required TResult Function(Exception e) error,
  }) {
    return error(e);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<Discussion> data)? loaded,
    TResult? Function(Exception e)? error,
  }) {
    return error?.call(e);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<Discussion> data)? loaded,
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
    required TResult Function(DiscussionListStateLoading value) loading,
    required TResult Function(DiscussionListStateLoaded value) loaded,
    required TResult Function(DiscussionListStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DiscussionListStateLoading value)? loading,
    TResult? Function(DiscussionListStateLoaded value)? loaded,
    TResult? Function(DiscussionListStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DiscussionListStateLoading value)? loading,
    TResult Function(DiscussionListStateLoaded value)? loaded,
    TResult Function(DiscussionListStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class DiscussionListStateError implements DiscussionListState {
  const factory DiscussionListStateError(final Exception e) =
      _$DiscussionListStateErrorImpl;

  Exception get e;

  /// Create a copy of DiscussionListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionListStateErrorImplCopyWith<_$DiscussionListStateErrorImpl>
  get copyWith => throw _privateConstructorUsedError;
}
