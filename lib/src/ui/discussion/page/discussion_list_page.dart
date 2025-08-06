import 'dart:async';

import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscussionListPage extends StatelessWidget {
  const DiscussionListPage({required this.currentUser, super.key});

  final User currentUser;

  Future<bool?> _showDeleteDiscussionConfirmation({
    required BuildContext context,
    required String discussionTitle,
  }) {
    return context.showAsActionBottomSheet(
      title: Text('Delete the discussion "$discussionTitle"?'),
      actions: [
        AsDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
      cancelAction: AsDialogAction(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
    );
  }

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
      body: BlocProvider(
        create: (context) => DiscussionListCubit(),
        child: BlocBuilder<DiscussionListCubit, DiscussionListState>(
          builder: (context, state) {
            return switch (state) {
              DiscussionListStateLoading() => const Center(
                child: AsLoadingCircular(),
              ),
              DiscussionListStateLoaded(:final data) =>
                data.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No discussions yet',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a new discussion to get started',
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Text(
                                'Tap the "+" button to'
                                ' create a new discussion.',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        children: AsListTile.divideTiles(
                          tiles: data.map((discussion) {
                            return Dismissible(
                              key: Key(discussion.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                final cubit = context
                                    .read<DiscussionListCubit>();
                                final shouldDelete =
                                    await _showDeleteDiscussionConfirmation(
                                      context: context,
                                      discussionTitle: discussion.title,
                                    );
                                if (shouldDelete ?? false) {
                                  await cubit.deleteDiscussion(discussion.id);
                                }
                                return shouldDelete;
                              },
                              child: DiscussionListTileWidget(
                                currentUser: currentUser,
                                discussion: discussion,
                              ),
                            );
                          }).toList(),
                        ).toList(),
                      ),
              DiscussionListStateError(:final e) => Center(child: Text('$e')),
            };
          },
        ),
      ),
    );
  }
}
