import 'dart:io';
import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/chat/chat.dart';
import 'package:chat_flutter_app/chat/cubit/chat_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.discussion,
    required this.currentUser,
    super.key,
  });

  final Discussion discussion;
  final User currentUser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Discussion? _discussion;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  late User _currentUser;
  bool _isSending = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessages = {};
  Message? _replyToMessage;
  XFile? _selectedImage;
  String? _recordedAudioPath;

  @override
  void initState() {
    super.initState();
    _discussion = widget.discussion;
    _currentUser = widget.currentUser;
    _messageFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (_discussion != null) {
      setState(() {
        _isSending = true;
      });

      if (text.isNotEmpty) {
        await MessageService.instance.sendMessage(
          discussionId: _discussion!.id,
          senderId: _currentUser.id,
          content: text,
          replyToId: _replyToMessage?.id,
        );
      }

      if (_selectedImage != null) {
        try {
          final imageFile = File(_selectedImage!.path);
          final downloadUrl = await StorageService.instance.uploadChatImage(
            file: imageFile,
            userId: _currentUser.id,
            discussionId: widget.discussion.id,
          );

          await MessageService.instance.sendMessage(
            discussionId: _discussion!.id,
            senderId: _currentUser.id,
            content: downloadUrl,
            type: MessageType.image,
            replyToId: _replyToMessage?.id,
          );
        } on Exception catch (e) {
          logger.e('Error uploading image', error: e);

          await MessageService.instance.sendMessage(
            discussionId: _discussion!.id,
            senderId: _currentUser.id,
            content: _selectedImage!.path,
            type: MessageType.image,
            replyToId: _replyToMessage?.id,
          );
        }
      }

      if (_recordedAudioPath != null) {
        try {
          final audioFile = File(_recordedAudioPath!);
          final downloadUrl = await StorageService.instance.uploadChatAudio(
            file: audioFile,
            userId: _currentUser.id,
            discussionId: widget.discussion.id,
          );

          await MessageService.instance.sendMessage(
            discussionId: _discussion!.id,
            senderId: _currentUser.id,
            content: downloadUrl,
            type: MessageType.audio,
            replyToId: _replyToMessage?.id,
          );
        } on Exception catch (e) {
          logger.e('Error uploading audio', error: e);

          await MessageService.instance.sendMessage(
            discussionId: _discussion!.id,
            senderId: _currentUser.id,
            content: _recordedAudioPath!,
            type: MessageType.audio,
            replyToId: _replyToMessage?.id,
          );
        }
      }

      setState(() {
        _selectedImage = null;
        _recordedAudioPath = null;
        _messageController.clear();
        _replyToMessage = null;
        _isSending = false;
      });
    }
  }

  Future<void> _onImageSelected(XFile image) async {
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _onAudioRecorded(String audioPath) async {
    setState(() {
      _recordedAudioPath = audioPath;
    });
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
        if (_selectedMessages.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessages.add(messageId);
        _isSelectionMode = true;
      }
    });
  }

  void _showMessageContextMenu(BuildContext context, Message message) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        const PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              Icon(Icons.reply, size: 18),
              SizedBox(width: 8),
              Text('Reply'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'reply') {
        _setReplyToMessage(message);
      } else if (value == 'delete') {
        _toggleMessageSelection(message.id);
      }
    });
  }

  void _setReplyToMessage(Message message) {
    setState(() {
      _replyToMessage = message;
    });

    _messageFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessages.clear();
    });
  }

  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessages.isEmpty) return;

    final shouldDelete = await _showBulkDeleteConfirmation(
      _selectedMessages.length,
    );
    if ((shouldDelete ?? false) && _discussion != null) {
      for (final messageId in _selectedMessages) {
        await SyncService.instance.deleteMessage(
          messageId,
          widget.discussion.id,
        );
        await MessageService.instance.deleteMessage(
          messageId,
          widget.discussion.id,
        );
      }

      setState(_exitSelectionMode);
    }
  }

  Future<bool?> _showBulkDeleteConfirmation(int messageCount) {
    return context.showAsAlertDialog(
      title: const Text('Delete Messages'),
      content: Text(
        'Are you sure you want to delete $messageCount selected messages?',
      ),
      actions: [
        AsDialogAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        AsDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete All'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsScaffold(
      appBar: AsAppBar(
        backgroundColor: _isSelectionMode
            ? Colors.red[100]
            : Theme.of(context).colorScheme.inversePrimary,
        title: _isSelectionMode
            ? Text('${_selectedMessages.length} selected')
            : Text(_discussion!.title),
        leading: _isSelectionMode
            ? AsButton.ghost(
                onPressed: _exitSelectionMode,
                child: const Icon(Icons.close),
              )
            : null,
        actions: [
          if (_isSelectionMode)
            AsButton.ghost(
              onPressed: _deleteSelectedMessages,
              child: const Icon(Icons.delete),
            ),
        ],
      ),
      body: BlocProvider(
        create: (context) => ChatListCubit(widget.discussion.id),
        child: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            return switch (state) {
              ChatListStateLoaded(:final messages) => GestureDetector(
                onTap: _messageFocusNode.unfocus,
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isCurrentUser =
                                message.senderId == _currentUser.id;
                            final isSelected = _selectedMessages.contains(
                              message.id,
                            );

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 8,
                              ),
                              child: Align(
                                alignment: isCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: _isSelectionMode && isCurrentUser
                                      ? () =>
                                            _toggleMessageSelection(message.id)
                                      : null,
                                  onLongPress: () =>
                                      _showMessageContextMenu(context, message),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 280,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.red[200]
                                          : isCurrentUser
                                          ? Colors.blue[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.red[400]!,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (message.replyToId != null)
                                          ReplyContextWidget(
                                            replyToMessageId:
                                                message.replyToId!,
                                          ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isSelected)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: Icon(
                                                  Icons.check_circle,
                                                  size: 16,
                                                  color: Colors.red[600],
                                                ),
                                              ),
                                            Expanded(
                                              child: Text(
                                                message.senderId,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        MessageContentWidget(message: message),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${message.timestamp.hour}:'
                                              '${message.timestamp.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            if (isCurrentUser &&
                                                !_isSelectionMode) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                'Long press for options',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.grey[500],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                            if (isCurrentUser &&
                                                _isSelectionMode) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                'Tap to toggle',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.grey[500],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Column(
                        children: [
                          if (_replyToMessage != null)
                            ReplyPreviewWidget(
                              replyToMessage: _replyToMessage!,
                              discussion: _discussion!,
                              onCancel: _cancelReply,
                            ),
                          MessageInput(
                            focusNode: _messageFocusNode,
                            messageController: _messageController,
                            onSendMessage: (_) => _sendMessage(),
                            onImageSelected: _onImageSelected,
                            onAudioRecorded: _onAudioRecorded,
                            selectedImage: _selectedImage,
                            recordedAudioPath: _recordedAudioPath,
                            isSending: _isSending,
                            onRemoveImage: () => setState(() {
                              _selectedImage = null;
                            }),
                            onRemoveAudio: () => setState(() {
                              _recordedAudioPath = null;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ChatListStateError() => const Center(
                child: Text('Error loading messages'),
              ),
            };
          },
        ),
      ),
    );
  }
}
