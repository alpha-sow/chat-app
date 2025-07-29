import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    required this.user,
    this.confirmDismiss,
    this.onDismissed,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final User user;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDismissed;

  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Dismissible(
        key: Key(user.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 32),
        ),
        confirmDismiss: confirmDismiss,
        onDismissed: onDismissed,
        child: ListTile(
          leading: UserAvatar(user),
          title: Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.email != null && user.email!.isNotEmpty)
                Text(user.email!),
              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                Text(user.phoneNumber!),
            ],
          ),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
