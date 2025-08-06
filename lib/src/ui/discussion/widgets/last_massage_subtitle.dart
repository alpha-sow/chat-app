import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';

class LastMessageSubtitle extends StatelessWidget {
  const LastMessageSubtitle({required this.message, super.key});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Text('No messages yet');
    }

    switch (message!.type) {
      case MessageType.text:
        return Text(message!.content);
      case MessageType.image:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.image),
            Text('Image'),
          ],
        );
      case MessageType.audio:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.mic),
            Text('Audio'),
          ],
        );
      case MessageType.video:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.videocam),
            Text('Video'),
          ],
        );
      case MessageType.file:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.attach_file),
            Text('File'),
          ],
        );
    }
  }
}
