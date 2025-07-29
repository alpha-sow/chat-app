import 'package:flutter/material.dart';
import 'package:chat_app_package/chat_app_package.dart';

import 'chat_page.dart';
import 'contact_page.dart';
import 'connectivity_handler.dart';
import 'utils/utils.dart';

class DiscussionListPage extends StatefulWidget {
  final User currentUser;

  const DiscussionListPage({super.key, required this.currentUser});

  @override
  State<DiscussionListPage> createState() => _DiscussionListPageState();
}

class _DiscussionListPageState extends State<DiscussionListPage> {
  List<DiscussionState> _discussions = [];
  bool _isLoading = true;
  SyncStatus _syncStatus = const SyncStatus(
    isOnline: false,
    pendingOperations: 0,
    syncInProgress: false,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load existing discussions from local database
      _discussions = await Discussion.getAllDiscussionsFromDatabase();
      
      // Trigger sync to get latest data from remote
      await SyncService.instance.syncAll();
      
      // Reload after sync
      _discussions = await Discussion.getAllDiscussionsFromDatabase();
      
      // Update sync status
      _syncStatus = SyncService.instance.syncStatus;
    } catch (e) {
      logger.e('Error loading data', error: e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteDiscussion(DiscussionState discussion) async {
    final shouldDelete = await _showDeleteDiscussionConfirmation(
      discussion.title,
    );
    if (shouldDelete == true) {
      try {
        logger.w('Deleting discussion: ${discussion.title} (${discussion.id})');
        await SyncService.instance.deleteDiscussion(discussion.id);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Discussion "${discussion.title}" deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh the list
        await _loadData();
      } catch (e) {
        logger.e('Error deleting discussion', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete discussion: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteDiscussionConfirmation(String discussionTitle) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('chat App'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Sync status indicator
          IconButton(
            icon: Icon(
              _syncStatus.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: _syncStatus.isOnline ? Colors.green : Colors.red,
            ),
            onPressed: () => _showSyncStatus(),
            tooltip: _syncStatus.isOnline ? 'Online' : 'Offline',
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ContactPage(currentUser: widget.currentUser),
                ),
              );
            },
            tooltip: 'Contacts',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _discussions.isEmpty
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
            )
          : ListView.builder(
              itemCount: _discussions.length,
              itemBuilder: (context, index) {
                final discussion = _discussions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
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
                      try {
                        logger.w(
                          'Deleting discussion: ${discussion.title} (${discussion.id})',
                        );
                        await SyncService.instance.deleteDiscussion(discussion.id);

                        // Show success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Discussion "${discussion.title}" deleted',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                        // Refresh the list
                        await _loadData();
                      } catch (e) {
                        logger.e('Error deleting discussion', error: e);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
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
            ),
    );
  }

  void _showSyncStatus() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sync Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _syncStatus.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: _syncStatus.isOnline ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _syncStatus.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: _syncStatus.isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Pending operations: ${_syncStatus.pendingOperations}'),
              const SizedBox(height: 4),
              Text(
                'Sync in progress: ${_syncStatus.syncInProgress ? "Yes" : "No"}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (!_syncStatus.isOnline)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _loadData();
                },
                child: const Text('Retry Sync'),
              ),
          ],
        );
      },
    );
  }
}
