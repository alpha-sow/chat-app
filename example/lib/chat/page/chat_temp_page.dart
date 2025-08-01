import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/chat/chat.dart';
import 'package:flutter/material.dart';

class ChatTempPage extends StatefulWidget {
  const ChatTempPage({
    required this.discussion,
    required this.currentUser,
    required this.otherUser,
    super.key,
  });
  final DiscussionService discussion;
  final User currentUser;
  final User otherUser;

  @override
  State<ChatTempPage> createState() => _ChatTempPageState();
}

class _ChatTempPageState extends State<ChatTempPage> {
  late DiscussionService _discussion;
  final TextEditingController _messageController = TextEditingController();
  late User _currentUser;
  late User _otherUser;

  @override
  void initState() {
    super.initState();
    _discussion = widget.discussion;
    _currentUser = widget.currentUser;
    _otherUser = widget.otherUser;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _discussion.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final discussion = DiscussionService.withUsers(
      id: _discussion.id,
      title: _discussion.title,
      users: [_currentUser, _otherUser],
      persistToDatabase: true,
    );

    logger.i('Discussion persisted to database: ${discussion.id}');

    if (mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ChatPage(
            discussionId: discussion.id,
            currentUser: _currentUser,
            initialMessage: text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.otherUser.displayName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: ASAlertBanner(
                message: 'Send your first message to start the conversation',
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: widget.otherUser.avatarUrl != null
                          ? CachedNetworkImageProvider(
                              widget.otherUser.avatarUrl!,
                            )
                          : null,
                      child: widget.otherUser.avatarUrl == null
                          ? Text(
                              widget.otherUser.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.otherUser.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a conversation',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            MessageInput(
              messageController: _messageController,
              onSendMessage: (message) {
                _sendMessage();
                _messageController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
