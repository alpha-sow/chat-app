part of 'discussion_list_cubit.dart';

@freezed
sealed class DiscussionListState with _$DiscussionListState {
  const factory DiscussionListState.loading() = DiscussionListStateLoading;
  const factory DiscussionListState.loaded(List<Discussion> data) =
      DiscussionListStateLoaded;
}
