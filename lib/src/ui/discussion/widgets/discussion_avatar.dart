import 'package:chat_app_package/chat_app_package.dart';
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

    return CircleAvatar(
      backgroundColor: DiscussionConstants.avatarBackgroundColor,
      child: Text(
        displayText,
        style: DiscussionConstants.avatarTextStyle.copyWith(
          color: DiscussionConstants.avatarTextColor,
        ),
      ),
    );
  }
}
