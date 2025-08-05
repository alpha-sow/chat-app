import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/discussion/widgets/discussion_constants.dart';
import 'package:flutter/material.dart';

class LastMessageSubtitle extends StatelessWidget {
  const LastMessageSubtitle({required this.message, super.key});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Text(
        'No messages yet',
        style: DiscussionConstants.subtitleTextStyle,
      );
    }

    switch (message!.type) {
      case MessageType.text:
        return Text(
          message!.content,
          style: DiscussionConstants.subtitleTextStyle,
        );
      case MessageType.image:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.image,
              size: DiscussionConstants.iconSize,
              color: DiscussionConstants.subtitleColor,
            ),
            SizedBox(width: DiscussionConstants.spacing),
            Text(
              'Image',
              style: DiscussionConstants.subtitleTextStyle,
            ),
          ],
        );
      case MessageType.audio:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.mic,
              size: DiscussionConstants.iconSize,
              color: DiscussionConstants.subtitleColor,
            ),
            SizedBox(width: DiscussionConstants.spacing),
            Text(
              'Audio',
              style: DiscussionConstants.subtitleTextStyle,
            ),
          ],
        );
      case MessageType.video:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.videocam,
              size: DiscussionConstants.iconSize,
              color: DiscussionConstants.subtitleColor,
            ),
            SizedBox(width: DiscussionConstants.spacing),
            Text(
              'Video',
              style: DiscussionConstants.subtitleTextStyle,
            ),
          ],
        );
      case MessageType.file:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.attach_file,
              size: DiscussionConstants.iconSize,
              color: DiscussionConstants.subtitleColor,
            ),
            SizedBox(width: DiscussionConstants.spacing),
            Text(
              'File',
              style: DiscussionConstants.subtitleTextStyle,
            ),
          ],
        );
    }
  }
}
