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
  Discussion? _discussion;
  final TextEditingController _messageController = TextEditingController();
  User? _currentUser;
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessages = {};

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
      _discussion = await Discussion.loadFromDatabase(widget.discussionId);
      
      // Add initial message if provided
      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty && _currentUser != null) {
        _discussion!.addMessage(_currentUser!.id, widget.initialMessage!);
        logger.d('Added initial message to discussion: ${widget.initialMessage}');
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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _discussion != null && _currentUser != null) {
      setState(() {
        _discussion!.addMessage(_currentUser!.id, text);
        _messageController.clear();
      });
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    if (_discussion != null && _currentUser != null) {
      // Show confirmation dialog
      final shouldDelete = await _showDeleteConfirmation();
      if (shouldDelete == true) {
        setState(() {
          _discussion!.deleteMessage(messageId, _currentUser!.id);
        });
      }
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
      setState(() {
        for (final messageId in _selectedMessages) {
          _discussion!.deleteMessage(messageId, _currentUser!.id);
        }
        _exitSelectionMode();
      });
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedMessages,
                  tooltip: 'Delete selected messages',
                ),
              ]
            : null,
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
                        onLongPress: isCurrentUser
                            ? () => _toggleMessageSelection(message.id)
                            : null,
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
                                  if (isCurrentUser && !_isSelectionMode)
                                    GestureDetector(
                                      onTap: () => _deleteMessage(message.id),
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: Colors.red[400],
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
                                      'Long press to select',
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
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    tooltip: 'Send Message',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
