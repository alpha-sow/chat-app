import 'package:chat_app_package/chat_app_package.dart';
import 'package:flutter/material.dart';

class DiscussionTitle extends StatelessWidget {
  const DiscussionTitle({
    required this.discussion,
    required this.user,
    super.key,
  });

  final Discussion discussion;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final title = discussion.type == DiscussionType.group
        ? discussion.title
        : (user?.displayName ?? 'Unknown');

    return Text(title);
  }
}
