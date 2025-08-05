part of 'discussion_user_cubit.dart';

@freezed
sealed class DiscussionUserState with _$DiscussionUserState {
  const factory DiscussionUserState.loading() = DiscussionUserStateLoading;
  const factory DiscussionUserState.loaded(User user) =
      DiscussionUserStateLoaded;
  const factory DiscussionUserState.error(String message) =
      DiscussionUserStateError;
}
