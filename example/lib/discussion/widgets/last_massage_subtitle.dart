import 'package:chat_app_package/chat_app_package.dart';
import 'package:flutter/material.dart';

class LastMessageSubtitle extends StatelessWidget {
  const LastMessageSubtitle({required this.message, super.key});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Text(
        'No messages yet',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      );
    }

    const style = TextStyle(
      color: Colors.grey,
      fontSize: 12,
    );

    switch (message!.type) {
      case MessageType.text:
        return Text(
          message!.content,
          style: style,
        );
      case MessageType.image:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.image,
              size: 16,
              color: Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              'Image',
              style: style,
            ),
          ],
        );
      case MessageType.audio:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.mic,
              size: 16,
              color: Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              'Audio',
              style: style,
            ),
          ],
        );
      case MessageType.video:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.videocam,
              size: 16,
              color: Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              'Video',
              style: style,
            ),
          ],
        );
      case MessageType.file:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.attach_file,
              size: 16,
              color: Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              'File',
              style: style,
            ),
          ],
        );
    }
  }
}
