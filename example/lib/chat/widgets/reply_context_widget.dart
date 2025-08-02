import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/chat/chat.dart';
import 'package:flutter/material.dart';

class ReplyContextWidget extends StatelessWidget {
  const ReplyContextWidget({
    required this.discussion,
    required this.replyToMessage,
    super.key,
  });

  final Discussion discussion;
  final Message replyToMessage;

  @override
  Widget build(BuildContext context) {
    try {
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
              '${replyToMessage.senderId}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 2),
            MessageContentWidget(message: replyToMessage),
          ],
        ),
      );
    } on Exception {
      return const SizedBox.shrink();
    }
  }
}
