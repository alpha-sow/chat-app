import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ReplyPreviewWidget extends StatelessWidget {
  const ReplyPreviewWidget({
    required this.replyToMessageId,
    required this.discussion,
    required this.onCancel,
    super.key,
  });

  final String replyToMessageId;
  final DiscussionService discussion;
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
                  MessageContentWidget(message: replyToMessage),
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
