import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/discussion/widgets/widgets.dart';
import 'package:chat_flutter_app/message/message.dart';
import 'package:flutter/material.dart';

class DiscussionListTileWidget extends StatelessWidget {
  const DiscussionListTileWidget({
    required this.discussion,
    required this.currentUser,
    super.key,
  });

  final User currentUser;
  final Discussion discussion;

  @override
  Widget build(BuildContext context) {
    return AsListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          discussion.type == DiscussionType.group
              ? discussion.title[0].toUpperCase()
              : 'Username'[0],
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: discussion.type == DiscussionType.group
          ? Text(discussion.title)
          : const Text('User name'),
      subtitle: LastMessageSubtitle(
        message: discussion.lastMessage,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => MessagePage(
              discussion: discussion,
              currentUser: currentUser,
            ),
          ),
        );
      },
    );
  }
}
