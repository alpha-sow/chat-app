import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion_list_state.dart';
part 'discussion_list_cubit.freezed.dart';

class DiscussionListCubit extends Cubit<DiscussionListState> {
  DiscussionListCubit() : super(const DiscussionListStateLoading()) {
    _discussionListSubscription = DiscussionService.instance
        .watchAllDiscussions()
        .listen(
          (discussions) {
            if (discussions.isEmpty) {
              emit(const DiscussionListStateLoaded([]));
            } else {
              emit(DiscussionListState.loaded(discussions));
            }
          },
          onError: (Object error) {
            emit(
              DiscussionListState.error(
                error is Exception ? error : Exception(error.toString()),
              ),
            );
          },
        );
  }

  late StreamSubscription<List<Discussion>> _discussionListSubscription;

  Future<void> deleteDiscussion(String discussionId) async {
    try {
      await DiscussionService.instance.deleteDiscussion(discussionId);
    } on Exception catch (e) {
      emit(DiscussionListState.error(e));
    }
  }

  @override
  Future<void> close() {
    _discussionListSubscription.cancel();
    return super.close();
  }
}
