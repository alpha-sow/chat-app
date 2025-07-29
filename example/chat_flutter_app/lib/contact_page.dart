import 'package:chat_flutter_app/create_discussion_group_page.dart';
import 'package:chat_flutter_app/temp_chat_page.dart';
import 'package:chat_flutter_app/contact_add_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_package/chat_app_package.dart';

import 'utils/utils.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({required this.currentUser, super.key});

  final User currentUser;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
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
      MaterialPageRoute(
        builder: (context) => const ContactAddPage(),
      ),
    );

    if (result != null) {
      // Refresh the contacts list
      _loadUsers();
    }
  }

  Future<void> _createGroupDiscussion() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => CreateDiscussionGroupPage(
          availableUsers: _users,
          currentUser: _currentUser!, // Use first user as current user
        ),
      ),
    );

    if (result != null) {
      final title = result['title'] as String;
      final selectedUsers = result['users'] as List<User>;

      // Create new discussion
      logger.i(
        'Creating new discussion: $title with ${selectedUsers.length} users',
      );
      final discussion = DiscussionService.withUsers(
        title: title,
        users: selectedUsers,
        persistToDatabase: true,
      );

      // Add welcome message with variety
      if (selectedUsers.isNotEmpty) {
        final welcomeMessages = [
          'Welcome to $title! 👋',
          'Hello everyone! 🎉 Welcome to $title',
          'Great to have you all here in $title! ✨',
          'Welcome to our new discussion: $title 🚀',
          'Hey team! Welcome to $title 💬',
          '${faker.lorem.sentence()} Welcome to $title!',
        ];

        final welcomeMessage = faker.randomGenerator.element(welcomeMessages);
        discussion.addMessage(selectedUsers.first.id, welcomeMessage);
        logger.d('Added welcome message to discussion: ${discussion.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
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
                return _buildUserTile(user);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroupDiscussion,
        tooltip: 'Create Group Discussion',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserTile(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildAvatar(user),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null && user.email!.isNotEmpty) Text(user.email!),
            if (user.status.isNotEmpty)
              Text(
                user.status,
                style: TextStyle(
                  color: _getStatusColor(user),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: _buildOnlineIndicator(user),
        onTap: () => _starChatWithUser(user),
        onLongPress: () => _showUserDetails(user),
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      backgroundImage: user.avatarUrl != null
          ? NetworkImage(user.avatarUrl!)
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

  Widget _buildOnlineIndicator(User user) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: user.isOnline ? Colors.green : Colors.grey,
      ),
    );
  }

  Color _getStatusColor(User user) {
    if (!user.isOnline) return Colors.grey;

    switch (user.status.toLowerCase()) {
      case 'busy':
        return Colors.red;
      case 'available':
        return Colors.green;
      case 'away':
        return Colors.orange;
      default:
        return Colors.blue;
    }
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
    // Get current user (using first available user as current user for now)

    // Create a temporary discussion that won't be persisted until first message
    final tempDiscussion = DiscussionService.withUsers(
      title: user.displayName,
      users: [_currentUser!, user],
      persistToDatabase: false, // Don't persist yet
    );

    // Navigate to chat page with the temporary discussion
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
