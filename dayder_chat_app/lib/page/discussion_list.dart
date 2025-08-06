import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';

class DiscussionList extends StatelessWidget {
  const DiscussionList({required this.currentUser, super.key});
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return AsScaffold(
      appBar: AsAppBar(
        title: const Text('Discussions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          AsIconButton.ghost(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      UserNewDiscussionPage(currentUser: currentUser),
                ),
              );
            },
            icon: Icons.add_circle,
          ),
        ],
      ),
      body: DiscussionListView(
        currentUser: currentUser,
        onDiscussionTap: (discussion) {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => MessagePage(
                discussion: discussion,
                currentUser: currentUser,
              ),
            ),
          );
        },
      ),
    );
  }
}
