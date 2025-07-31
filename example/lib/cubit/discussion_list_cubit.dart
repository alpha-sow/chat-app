import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion_list_state.dart';
part 'discussion_list_cubit.freezed.dart';

class DiscussionListCubit extends Cubit<DiscussionListState> {
  DiscussionListCubit() : super(const DiscussionListStateLoading()) {
    _discussionListSubscription = DiscussionService.watchAllDiscussions()
        .listen((data) {
          emit(DiscussionListState.loaded(data));
        });
  }

  late StreamSubscription<List<Discussion>> _discussionListSubscription;

  @override
  Future<void> close() {
    _discussionListSubscription.cancel();
    return super.close();
  }
}
