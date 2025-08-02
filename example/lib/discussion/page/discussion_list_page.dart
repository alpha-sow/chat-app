import 'dart:async';

import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/chat/chat.dart';
import 'package:chat_flutter_app/discussion/discussion.dart';
import 'package:chat_flutter_app/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscussionListPage extends StatefulWidget {
  const DiscussionListPage({required this.currentUser, super.key});

  final User currentUser;

  @override
  State<DiscussionListPage> createState() => _DiscussionListPageState();
}

class _DiscussionListPageState extends State<DiscussionListPage> {
  @override
  void initState() {
    super.initState();
    _initSync();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initSync() async {
    try {
      await SyncService.instance.syncAll();
    } on Exception catch (e) {
      logger.e('Error during initial sync', error: e);
    }
  }

  Future<bool?> _showDeleteDiscussionConfirmation(String discussionTitle) {
    return context.showAsAlertDialog(
      title: const Text('Delete Discussion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to delete "$discussionTitle"?'),
          const SizedBox(height: 8),
          const Text(
            'This will permanently delete all messages and cannot be undone.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        AsDialogAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        AsDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsScaffold(
      appBar: AsAppBar(
        title: const Text('Discussions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          AsButton.ghost(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      UserNewDiscussionPage(currentUser: widget.currentUser),
                ),
              );
            },
            child: const Icon(Icons.add_circle),
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
                          children: [
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
                                '💡 Tips:\n• You are automatically included in all '
                                'discussions\n• Select other participants to '
                                'auto-generate titles\n• Example: "Chat with Alice" '
                                'or "Alice & Bob"\n• Edit title manually for custom '
                                'names\n• Tap to open chat, swipe left to delete',
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
                        children: ASListTile.divideTiles(
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
                                return _showDeleteDiscussionConfirmation(
                                  discussion.title,
                                );
                              },
                              onDismissed: (direction) async {
                                try {
                                  logger.w(
                                    'Deleting discussion: ${discussion.title} (${discussion.id})',
                                  );
                                  await SyncService.instance.deleteDiscussion(
                                    discussion.id,
                                  );

                                  if (mounted && context.mounted) {
                                    context.showBanner(
                                      message:
                                          'Discussion "${discussion.title}" deleted',
                                      type: AlertType.success,
                                    );
                                  }
                                } on Exception catch (e) {
                                  logger.e(
                                    'Error deleting discussion',
                                    error: e,
                                  );
                                  if (mounted && context.mounted) {
                                    context.showBanner(
                                      message:
                                          'Failed to delete discussion: $e',
                                      type: AlertType.error,
                                    );
                                  }
                                }
                              },
                              child: ASListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    discussion.title[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(discussion.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${discussion.participantCount} participants',
                                    ),
                                    Text(
                                      '${discussion.messageCount} messages',
                                      style: TextStyle(
                                        color: Colors.green[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) => ChatPage(
                                        discussion: discussion,
                                        currentUser: widget.currentUser,
                                      ),
                                    ),
                                  );
                                },
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
