import 'dart:io';
import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageContentWidget extends StatelessWidget {
  const MessageContentWidget({
    required this.message,
    super.key,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return _ImageMessageWidget(imagePath: message.content);
      case MessageType.audio:
        return _AudioMessageWidget(audioPath: message.content);
      case MessageType.text:
      case MessageType.file:
      case MessageType.video:
        return Text(message.content);
    }
  }
}

class _ImageMessageWidget extends StatelessWidget {
  const _ImageMessageWidget({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(
                    'Image not found',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AudioMessageWidget extends StatelessWidget {
  const _AudioMessageWidget({required this.audioPath});

  final String audioPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.audiotrack, color: Colors.blue[600]),
          const SizedBox(width: 8),
          const Text('Audio message'),
        ],
      ),
    );
  }
}

class ReplyContextWidget extends StatelessWidget {
  const ReplyContextWidget({
    required this.replyToId,
    required this.discussion,
    super.key,
  });

  final String replyToId;
  final ChatService discussion;

  @override
  Widget build(BuildContext context) {
    try {
      final replyToMessage = discussion.messages.firstWhere(
        (m) => m.id == replyToId,
      );

      final replyToUser = discussion.getUser(replyToMessage.senderId);

      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: Colors.blue[300]!, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replying to '
              '${replyToUser?.displayName ?? replyToMessage.senderId}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              replyToMessage.content,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } on Exception {
      return const SizedBox.shrink();
    }
  }
}

class ReplyPreviewWidget extends StatelessWidget {
  const ReplyPreviewWidget({
    required this.replyToMessageId,
    required this.discussion,
    required this.onCancel,
    super.key,
  });

  final String replyToMessageId;
  final ChatService discussion;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    try {
      final replyToMessage = discussion.messages.firstWhere(
        (m) => m.id == replyToMessageId,
      );

      final replyToUser = discussion.getUser(replyToMessage.senderId);

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Icon(Icons.reply, size: 16, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replying to '
                    '${replyToUser?.displayName ?? replyToMessage.senderId}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                  Text(
                    replyToMessage.content,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ASButton.ghost(
              onPressed: onCancel,
              child: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
    } on Exception {
      return const SizedBox.shrink();
    }
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.discussionId,
    required this.currentUserId,
    this.initialMessage,
    super.key,
  });

  final String discussionId;
  final String currentUserId;
  final String? initialMessage;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatService? _discussion;
  final TextEditingController _messageController = TextEditingController();
  User? _currentUser;
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessages = {};
  String? _replyToMessageId;
  XFile? _selectedImage;
  String? _recordedAudioPath;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      _currentUser = await LocalDatabaseService.instance.getUser(
        widget.currentUserId,
      );

      _discussion = await ChatService.loadFromDatabase(
        widget.discussionId,
      );

      if (widget.initialMessage != null &&
          widget.initialMessage!.isNotEmpty &&
          _currentUser != null) {
        _discussion!.sendMessage(_currentUser!.id, widget.initialMessage!);
        logger.d(
          'Added initial message to discussion: ${widget.initialMessage}',
        );
      }
    } on Exception catch (e) {
      logger.e('Error loading chat', error: e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _discussion?.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? messageText]) async {
    final text = messageText ?? _messageController.text.trim();

    if (_discussion != null && _currentUser != null) {
      // Send text message if there is text
      if (text.isNotEmpty) {
        _discussion!.sendMessage(
          _currentUser!.id,
          text,
          replyToId: _replyToMessageId,
        );
      }

      // Send image if selected
      if (_selectedImage != null) {
        _discussion!.sendMessage(
          _currentUser!.id,
          _selectedImage!.path,
          type: MessageType.image,
          replyToId: _replyToMessageId,
        );
      }

      // Send audio if recorded
      if (_recordedAudioPath != null) {
        _discussion!.sendMessage(
          _currentUser!.id,
          _recordedAudioPath!,
          type: MessageType.audio,
          replyToId: _replyToMessageId,
        );
      }

      setState(() {
        _selectedImage = null;
        _recordedAudioPath = null;
        _messageController.clear();
        _replyToMessageId = null;
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

  void _showMessageContextMenu(BuildContext context, String messageId) {
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
        _replyToMessage(messageId);
      } else if (value == 'delete') {
        _toggleMessageSelection(messageId);
      }
    });
  }

  void _replyToMessage(String messageId) {
    setState(() {
      _replyToMessageId = messageId;
    });

    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyToMessageId = null;
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
    if ((shouldDelete ?? false) &&
        _discussion != null &&
        _currentUser != null) {
      for (final messageId in _selectedMessages) {
        await SyncService.instance.deleteMessage(
          messageId,
          widget.discussionId,
        );
        _discussion!.deleteMessage(messageId, _currentUser!.id);
      }

      setState(_exitSelectionMode);
    }
  }

  Future<bool?> _showBulkDeleteConfirmation(int messageCount) {
    return context.showASAlertDialog(
      title: const Text('Delete Messages'),
      content: Text(
        'Are you sure you want to delete $messageCount selected messages?',
      ),
      actions: [
        ASButton.ghost(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ASButton.destructive(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete All'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentUser == null || _discussion == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Loading...'),
        ),
        body: const Center(child: ASLoadingCircular()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _isSelectionMode
            ? Colors.red[100]
            : Theme.of(context).colorScheme.inversePrimary,
        title: _isSelectionMode
            ? Text('${_selectedMessages.length} selected')
            : Text(_discussion!.title),
        leading: _isSelectionMode
            ? ASButton.ghost(
                onPressed: _exitSelectionMode,
                child: const Icon(Icons.close),
              )
            : null,
        actions: [
          if (_isSelectionMode)
            ASButton.ghost(
              onPressed: _deleteSelectedMessages,
              child: const Icon(Icons.delete),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _discussion?.messages.length ?? 0,
                itemBuilder: (context, index) {
                  final message = _discussion!.messages[index];
                  final user = _discussion!.getUser(message.senderId);
                  final isCurrentUser = message.senderId == _currentUser!.id;
                  final isSelected = _selectedMessages.contains(message.id);

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
                            ? () => _toggleMessageSelection(message.id)
                            : null,
                        onLongPress: () =>
                            _showMessageContextMenu(context, message.id),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),
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
                                ? Border.all(color: Colors.red[400]!, width: 2)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.replyToId != null)
                                ReplyContextWidget(
                                  replyToId: message.replyToId!,
                                  discussion: _discussion!,
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      user?.displayName ?? message.senderId,
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
                                  if (isCurrentUser && !_isSelectionMode) ...[
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
                                  if (isCurrentUser && _isSelectionMode) ...[
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
                if (_replyToMessageId != null)
                  ReplyPreviewWidget(
                    replyToMessageId: _replyToMessageId!,
                    discussion: _discussion!,
                    onCancel: _cancelReply,
                  ),
                MessageInput(
                  messageController: _messageController,
                  onSendMessage: (message) => _sendMessage(),
                  onImageSelected: _onImageSelected,
                  onAudioRecorded: _onAudioRecorded,
                  selectedImage: _selectedImage,
                  recordedAudioPath: _recordedAudioPath,
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
    );
  }
}
