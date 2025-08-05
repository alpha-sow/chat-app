import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return AsAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      backgroundImage: user.avatarUrl != null
          ? CachedNetworkImageProvider(user.avatarUrl!)
          : null,
      child: user.avatarUrl == null
          ? Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
