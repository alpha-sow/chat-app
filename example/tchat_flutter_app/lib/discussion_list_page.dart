import 'package:flutter/material.dart';
import 'package:tchat_app/tchat_app.dart';

import 'chat_page.dart';
import 'contact_page.dart';
import 'utils/utils.dart';

class DiscussionListPage extends StatefulWidget {
  const DiscussionListPage({super.key});

  @override
  State<DiscussionListPage> createState() => _DiscussionListPageState();
}

class _DiscussionListPageState extends State<DiscussionListPage> {
  List<DiscussionState> _discussions = [];
  List<User> _availableUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load existing discussions
      _discussions = await Discussion.getAllDiscussionsFromDatabase();

      // Load available users or create some sample users
      _availableUsers = await DatabaseService.instance.getAllUsers();

      if (_availableUsers.isEmpty) {
        // Create realistic sample users if none exist
        _availableUsers = List.generate(10, (index) {
          final id = (index + 1).toString();
          final isOnline = faker.randomGenerator.boolean();
          return User(
            id: id,
            name: faker.person.name(),
            email: faker.internet.email(),
            isOnline: isOnline,
            status: isOnline ? 'Available' : 'Away',
            avatarUrl: faker.image.image(
              width: 100,
              height: 100,
              keywords: ['person', 'avatar'],
              random: true,
            ),
            lastSeen: isOnline
                ? null
                : faker.date.dateTime(minYear: 2024, maxYear: 2025),
          );
        });

        // Save sample users to database
        for (final user in _availableUsers) {
          await DatabaseService.instance.saveUser(user);
        }
      }
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
        await Discussion.deleteFromDatabase(discussion.id);

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
          title: const Text('TChat App'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TChat App - Discussions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ContactPage()),
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
                        await Discussion.deleteFromDatabase(discussion.id);

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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red[400],
                            ),
                            onPressed: () => _deleteDiscussion(discussion),
                            tooltip: 'Delete Discussion',
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              discussionId: discussion.id,
                              currentUserId: _availableUsers.first.id,
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
}
