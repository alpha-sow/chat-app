import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:flutter/material.dart';

class DiscussionLoadedTile extends StatelessWidget {
  const DiscussionLoadedTile({
    required this.discussion,
    required this.currentUser,
    required this.user,
    super.key,
  });

  final Discussion discussion;
  final User currentUser;
  final User user;

  @override
  Widget build(BuildContext context) {
    return AsListTile(
      leading: DiscussionAvatar(
        discussion: discussion,
        user: user,
      ),
      title: DiscussionTitle(
        discussion: discussion,
        user: user,
      ),
      subtitle: LastMessageSubtitle(
        message: discussion.lastMessage,
      ),
      trailing: Icon(
        Icons.adaptive.arrow_forward,
        color: DiscussionConstants.trailingIconColor,
      ),
      onTap: () => _navigateToMessages(context),
    );
  }

  void _navigateToMessages(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MessagePage(
          discussion: discussion,
          currentUser: currentUser,
        ),
      ),
    );
  }
}
