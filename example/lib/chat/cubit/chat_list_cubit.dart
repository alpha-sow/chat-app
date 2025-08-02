import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_list_state.dart';
part 'chat_list_cubit.freezed.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit(String discussionId)
    : _discussionId = discussionId,
      super(const ChatListStateLoaded([])) {
    _messageStreamSubscription = MessageService.instance
        .watchMessagesForDiscussion(_discussionId)
        .listen(
          (messages) {
            if (messages.isEmpty) {
              emit(const ChatListStateLoaded([]));
            } else {
              emit(ChatListStateLoaded(messages));
            }
          },
          onError: (Object error) {
            emit(ChatListStateError(error as Exception));
          },
        );
  }

  late StreamSubscription<List<Message>> _messageStreamSubscription;
  final String _discussionId;

  @override
  Future<void> close() {
    _messageStreamSubscription.cancel();
    return super.close();
  }
}
