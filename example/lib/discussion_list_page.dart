import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:alphasow_ui/alphasow_ui.dart';

import 'chat_page.dart';
import 'discussion_new_page.dart';
import 'connectivity_handler.dart';
import 'utils/utils.dart';

class DiscussionListPage extends StatefulWidget {
  final User currentUser;

  const DiscussionListPage({super.key, required this.currentUser});

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
    } catch (e) {
      logger.e('Error during initial sync', error: e);
    }
  }

  Future<void> _deleteDiscussion(Discussion discussion) async {
    final shouldDelete = await _showDeleteDiscussionConfirmation(
      discussion.title,
    );
    if (shouldDelete == true) {
      try {
        logger.w('Deleting discussion: ${discussion.title} (${discussion.id})');
        await SyncService.instance.deleteDiscussion(discussion.id);

        // Show success message
        if (mounted) {
          context.showBanner(
            message: 'Discussion "${discussion.title}" deleted',
            type: AlertType.success,
          );
        }
      } catch (e) {
        logger.e('Error deleting discussion', error: e);
        if (mounted) {
          context.showBanner(
            message: 'Failed to delete discussion: $e',
            type: AlertType.error,
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteDiscussionConfirmation(String discussionTitle) {
    return context.showAlertDialog(
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
        Button(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        Button.destructive(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Sync status indicator
          Button.ghost(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DiscussionNewPage(currentUser: widget.currentUser),
                ),
              );
            },
            child: const Icon(Icons.add_circle),
          ),
        ],
      ),
      body: StreamBuilder<List<Discussion>>(
        stream: DiscussionService.watchAllDiscussions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingCircular());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading discussions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Button(
                    onPressed: () => SyncService.instance.syncAll(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final discussions = snapshot.data ?? [];

          if (discussions.isEmpty) {
            return Center(
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new discussion to get started',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      '💡 Tips:\n• You are automatically included in all discussions\n• Select other participants to auto-generate titles\n• Example: "Chat with Alice" or "Alice & Bob"\n• Edit title manually for custom names\n• Tap to open chat, swipe left to delete',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              final discussion = discussions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Dismissible(
                  key: Key(discussion.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteDiscussionConfirmation(
                      discussion.title,
                    );
                  },
                  onDismissed: (direction) async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      logger.w(
                        'Deleting discussion: ${discussion.title} (${discussion.id})',
                      );
                      await SyncService.instance.deleteDiscussion(
                        discussion.id,
                      );

                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Discussion "${discussion.title}" deleted',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      logger.e('Error deleting discussion', error: e);
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete discussion: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: ListTile(
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
                        Text('${discussion.participantCount} participants'),
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
                        MaterialPageRoute(
                          builder: (context) => ConnectionStatusWidget(
                            child: ChatPage(
                              discussionId: discussion.id,
                              currentUserId: widget.currentUser.id,
                            ),
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _deleteDiscussion(discussion),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
