import 'package:bloc/bloc.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_list_state.dart';
part 'user_list_cubit.freezed.dart';

class UserListCubit extends Cubit<UserListState> {
  UserListCubit() : super(const UserListStateLoading());

  Future<void> loadUserList() async {
    try {
      final data = await LocalDatabaseService.instance.getAllUsers();
      emit(UserListStateLoaded(data));
    } on Exception catch (e) {
      emit(UserListStateError(e));
    }
  }
}
