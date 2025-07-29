import 'package:chat_flutter_app/create_discussion_group_page.dart';
import 'package:chat_flutter_app/temp_chat_page.dart';
import 'package:chat_flutter_app/contact_add_page.dart';
import 'package:chat_flutter_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_package/chat_app_package.dart';

import 'utils/utils.dart';

class DiscussionNewPage extends StatefulWidget {
  const DiscussionNewPage({required this.currentUser, super.key});

  final User currentUser;

  @override
  State<DiscussionNewPage> createState() => _DiscussionNewPageState();
}

class _DiscussionNewPageState extends State<DiscussionNewPage> {
  List<User> _users = [];
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      _users = await DatabaseService.instance.getAllUsers();
    } catch (e) {
      logger.e('Error loading data', error: e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addContact() async {
    final result = await Navigator.of(context).push<User>(
      MaterialPageRoute(builder: (context) => const ContactAddPage()),
    );
    if (result != null) {
      _loadUsers();
    }
  }

  Future<bool?> _showDeleteContactConfirmation(String contactName) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete "$contactName"?'),
              const SizedBox(height: 8),
              const Text(
                'This will permanently remove the contact from your list.',
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

  Future<void> _deleteContact(User user) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      logger.w('Deleting contact: ${user.displayName} (${user.id})');
      await SyncService.instance.deleteUser(user.id);

      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Contact "${user.displayName}" deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logger.e('Error deleting contact', error: e);

      _loadUsers();

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createGroupDiscussion() async {
    await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => CreateDiscussionGroupPage(
          availableUsers: _users,
          currentUser: _currentUser!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Discussion'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _addContact,
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Contact',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(
              child: Text('No contacts found', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return UserTile(
                  user: user,
                  confirmDismiss: (_) =>
                      _showDeleteContactConfirmation(user.displayName),
                  onDismissed: (_) => _deleteContact(user),
                  onTap: () => _starChatWithUser(user),
                  onLongPress: () => _showUserDetails(user),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroupDiscussion,
        tooltip: 'Create Group Discussion',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null && user.email!.isNotEmpty)
              Text('Email: ${user.email}'),
            Text('Status: ${user.isOnline ? 'Online' : 'Offline'}'),
            if (user.status.isNotEmpty) Text('Message: ${user.status}'),
            if (user.isGuest) const Text('Type: Guest User'),
            if (user.lastSeen != null && !user.isOnline)
              Text('Last seen: ${_formatDateTime(user.lastSeen!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _starChatWithUser(user);
            },
            icon: const Icon(Icons.chat),
            label: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _starChatWithUser(User user) async {
    final tempDiscussion = DiscussionService.withUsers(
      title: user.displayName,
      users: [_currentUser!, user],
      persistToDatabase: false,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TempChatPage(
          discussion: tempDiscussion,
          currentUser: _currentUser!,
          otherUser: user,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
