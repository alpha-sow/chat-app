part of 'chat_list_cubit.dart';

@freezed
sealed class ChatListState with _$ChatListState {
  const factory ChatListState.loaded(List<Message> messages) =
      ChatListStateLoaded;
  const factory ChatListState.error(Exception error) = ChatListStateError;
}
