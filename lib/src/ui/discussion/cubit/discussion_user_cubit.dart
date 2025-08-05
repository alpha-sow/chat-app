import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion_user_state.dart';
part 'discussion_user_cubit.freezed.dart';

class DiscussionUserCubit extends Cubit<DiscussionUserState> {
  DiscussionUserCubit(
    String userId,
  ) : super(const DiscussionUserState.loading()) {
    unawaited(_loadUser(userId));
  }

  Future<void> _loadUser(String userId) async {
    try {
      final user = await UserService.instance().getUserById(userId);
      if (user == null) {
        emit(const DiscussionUserState.error('User not found'));
        return;
      }
      emit(DiscussionUserState.loaded(user));
    } on Exception catch (e) {
      emit(DiscussionUserState.error(e.toString()));
    }
  }
}
