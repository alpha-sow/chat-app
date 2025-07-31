part of 'user_list_cubit.dart';

@freezed
sealed class UserListState with _$UserListState {
  const factory UserListState.loading() = UserListStateLoading;
  const factory UserListState.loaded(List<User> data) = UserListStateLoaded;
  const factory UserListState.error(Exception e) = UserListStateError;
}
