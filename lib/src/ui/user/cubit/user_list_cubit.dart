import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_list_state.dart';
part 'user_list_cubit.freezed.dart';

class UserListCubit extends Cubit<UserListState> {
  UserListCubit() : super(const UserListStateLoading()) {
    _userSubscription = UserService.instance().watchAllUsers().listen(
      (users) {
        emit(UserListStateLoaded(users));
      },
      onError: (Object error) {
        emit(
          UserListStateError(
            error is Exception ? error : Exception(error.toString()),
          ),
        );
      },
    );
  }

  StreamSubscription<List<User>>? _userSubscription;

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
