import 'package:chat_flutter_app/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:alphasow_ui/alphasow_ui.dart';

import 'utils/utils.dart';

class TempChatPage extends StatefulWidget {
  final DiscussionService discussion;
  final User currentUser;
  final User otherUser;

  const TempChatPage({
    super.key,
    required this.discussion,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<TempChatPage> createState() => _TempChatPageState();
}

class _TempChatPageState extends State<TempChatPage> {
  late DiscussionService _discussion;
  final TextEditingController _messageController = TextEditingController();
  User? _currentUser;
  User? _otherUser;

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

    // Persist the discussion to database without adding the message yet
    final discussion = DiscussionService.withUsers(
      id: _discussion.id,
      title: _discussion.title,
      users: [_currentUser!, _otherUser!],
      persistToDatabase: true,
    );

    logger.i('Discussion persisted to database: ${discussion.id}');

    // Navigate to ChatPage and pass the message to be added after navigation
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            discussionId: discussion.id,
            currentUserId: _currentUser!.id,
            initialMessage: text, // Pass the message to be added after loading
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AlertBanner(
                type: AlertType.info,
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
                          ? NetworkImage(widget.otherUser.avatarUrl!)
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
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Input(
                      controller: _messageController,
                      hintText: 'Send first message to start chat...',
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Button.ghost(
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
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
