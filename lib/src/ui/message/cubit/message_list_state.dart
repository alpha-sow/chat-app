part of 'message_list_cubit.dart';

@freezed
sealed class MessageListState with _$MessageListState {
  const factory MessageListState.loaded(List<Message> messages) =
      MessageListStateLoaded;
  const factory MessageListState.error(Exception error) = MessageListStateError;
}
