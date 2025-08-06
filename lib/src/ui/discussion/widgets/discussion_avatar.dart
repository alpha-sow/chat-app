import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';

class DiscussionAvatar extends StatelessWidget {
  const DiscussionAvatar({
    required this.discussion,
    required this.user,
    super.key,
  });

  final Discussion discussion;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final displayText = discussion.type == DiscussionType.group
        ? discussion.title[0].toUpperCase()
        : (user?.displayName[0].toUpperCase() ?? '?');

    return CircleAvatar(child: Text(displayText));
  }
}
