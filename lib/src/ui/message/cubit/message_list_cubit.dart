import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_list_state.dart';
part 'message_list_cubit.freezed.dart';

class MassageListCubit extends Cubit<MessageListState> {
  MassageListCubit(String discussionId)
    : _discussionId = discussionId,
      super(const MessageListStateLoaded([])) {
    _messageStreamSubscription = MessageService.instance()
        .watchMessagesForDiscussion(_discussionId)
        .listen(
          (messages) {
            if (messages.isEmpty) {
              emit(const MessageListStateLoaded([]));
            } else {
              emit(MessageListStateLoaded(messages));
            }
          },
          onError: (Object error) {
            emit(MessageListStateError(error as Exception));
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
