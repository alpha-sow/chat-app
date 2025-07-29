import 'package:flutter/material.dart';
import 'package:chat_app_package/chat_app_package.dart';

import 'utils/utils.dart';

class ChatPage extends StatefulWidget {
  final String discussionId;
  final String currentUserId;
  final String? initialMessage;

  const ChatPage({
    super.key,
    required this.discussionId,
    required this.currentUserId,
    this.initialMessage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DiscussionService? _discussion;
  final TextEditingController _messageController = TextEditingController();
  User? _currentUser;
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessages = {};
  String? _replyToMessageId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user
      _currentUser = await DatabaseService.instance.getUser(
        widget.currentUserId,
      );

      // Load the discussion
      _discussion = await DiscussionService.loadFromDatabase(
        widget.discussionId,
      );

      // Add initial message if provided
      if (widget.initialMessage != null &&
          widget.initialMessage!.isNotEmpty &&
          _currentUser != null) {
        _discussion!.addMessage(_currentUser!.id, widget.initialMessage!);
        logger.d(
          'Added initial message to discussion: ${widget.initialMessage}',
        );
      }
    } catch (e) {
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _discussion != null && _currentUser != null) {
      setState(() {
        _discussion!.addMessage(
          _currentUser!.id,
          text,
          replyToId: _replyToMessageId,
        );
        _messageController.clear();
        _replyToMessageId = null;
      });
    }
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
        PopupMenuItem(
          value: 'reply',
          child: const Row(
            children: [
              Icon(Icons.reply, size: 18),
              SizedBox(width: 8),
              Text('Reply'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: const Row(
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

    // Focus the text field for reply
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget _buildReplyContext(String replyToId) {
    try {
      final replyToMessage = _discussion?.messages.firstWhere(
        (m) => m.id == replyToId,
      );

      if (replyToMessage == null) return const SizedBox.shrink();

      final replyToUser = _discussion!.getUser(replyToMessage.senderId);

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
              'Replying to ${replyToUser?.displayName ?? replyToMessage.senderId}',
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
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildReplyPreview() {
    try {
      final replyToMessage = _discussion?.messages.firstWhere(
        (m) => m.id == _replyToMessageId,
      );

      if (replyToMessage == null) return const SizedBox.shrink();

      final replyToUser = _discussion!.getUser(replyToMessage.senderId);

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
                    'Replying to ${replyToUser?.displayName ?? replyToMessage.senderId}',
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
            IconButton(
              onPressed: () {
                setState(() {
                  _replyToMessageId = null;
                });
              },
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Cancel reply',
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
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
    if (shouldDelete == true && _discussion != null && _currentUser != null) {
      // Delete from sync service (handles local + remote)
      for (final messageId in _selectedMessages) {
        await SyncService.instance.deleteMessage(
          messageId,
          widget.discussionId,
        );
        _discussion!.deleteMessage(messageId, _currentUser!.id);
      }

      setState(() {
        _exitSelectionMode();
      });
    }
  }

  Future<bool?> _showBulkDeleteConfirmation(int messageCount) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Messages'),
          content: Text(
            'Are you sure you want to delete $messageCount selected messages?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
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
        body: const Center(child: CircularProgressIndicator()),
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
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedMessages,
              tooltip: 'Delete selected messages',
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
                              // Show reply context if this message is a reply
                              if (message.replyToId != null)
                                _buildReplyContext(message.replyToId!),
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
                              Text(message.content),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
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
                // Reply preview bar
                if (_replyToMessageId != null) _buildReplyPreview(),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: _replyToMessageId != null
                                ? 'Reply to message...'
                                : 'Type a message...',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) async => await _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _sendMessage(),
                        icon: const Icon(Icons.send),
                        tooltip: 'Send Message',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
