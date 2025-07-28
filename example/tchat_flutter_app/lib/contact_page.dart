import 'package:flutter/material.dart';
import 'package:tchat_app/tchat_app.dart';
import 'package:tchat_flutter_app/create_discussion_page.dart';

import 'utils/utils.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      // Load available users or create some sample users
      _users = await DatabaseService.instance.getAllUsers();

      if (_users.isEmpty) {
        // Create realistic sample users if none exist
        _users = List.generate(10, (index) {
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
        for (final user in _users) {
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

  Future<void> _createNewDiscussion() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => CreateDiscussionPage(
          availableUsers: _users,
          currentUser: _users.first, // Use first user as current user
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
      final discussion = Discussion.withUsers(
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
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
        onPressed: _createNewDiscussion,
        tooltip: 'Create New Discussion',
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
        onTap: () => _startChatWithUser(user),
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
              _startChatWithUser(user);
            },
            icon: const Icon(Icons.chat),
            label: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _startChatWithUser(User user) async {
    // Get current user (using first available user as current user for now)
    final currentUser = _users.isNotEmpty ? _users.first : User.guest('Me');

    // Create a temporary discussion that won't be persisted until first message
    final tempDiscussion = Discussion.withUsers(
      title: 'Chat with ${user.displayName}',
      users: [currentUser, user],
      persistToDatabase: false, // Don't persist yet
    );

    // Navigate to chat page with the temporary discussion
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _TempChatPage(
          discussion: tempDiscussion,
          currentUserId: currentUser.id,
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

class _TempChatPage extends StatefulWidget {
  final Discussion discussion;
  final String currentUserId;
  final User otherUser;

  const _TempChatPage({
    required this.discussion,
    required this.currentUserId,
    required this.otherUser,
  });

  @override
  State<_TempChatPage> createState() => _TempChatPageState();
}

class _TempChatPageState extends State<_TempChatPage> {
  late Discussion _discussion;
  final TextEditingController _messageController = TextEditingController();
  User? _currentUser;
  bool _isLoading = true;
  bool _isPersisted = false;

  @override
  void initState() {
    super.initState();
    _discussion = widget.discussion;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user
      _currentUser = await DatabaseService.instance.getUser(
        widget.currentUserId,
      );
      // If user doesn't exist in database, use the one from the discussion
      _currentUser ??= _discussion.getUser(widget.currentUserId);
    } catch (e) {
      logger.e('Error loading chat', error: e);
      // Fallback to guest user
      _currentUser = User.guest('Me');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    if (_isPersisted) {
      _discussion.dispose();
    }
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _currentUser != null) {
      // If this is the first message, persist the discussion
      if (!_isPersisted) {
        try {
          _discussion = Discussion.withUsers(
            title: 'Chat with ${widget.otherUser.displayName}',
            users: [_currentUser!, widget.otherUser],
            persistToDatabase: true, // Don't persist yet
          );
          _isPersisted = true;
          logger.i('Discussion persisted to database: ${_discussion.id}');
        } catch (e) {
          logger.e(e);
          // Show error to user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save discussion: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Add the message
      setState(() {
        _discussion.addMessage(_currentUser!.id, text);
        _messageController.clear();
      });

      // Show success message for first message
      if (_isPersisted && _discussion.messages.length == 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Chat with ${widget.otherUser.displayName} started!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    if (_currentUser != null) {
      final shouldDelete = await _showDeleteConfirmation();
      if (shouldDelete == true) {
        setState(() {
          _discussion.deleteMessage(messageId, _currentUser!.id);
        });
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
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
    if (_isLoading || _currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Chat with ${widget.otherUser.displayName}'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Chat with ${widget.otherUser.displayName}'),
        actions: [
          if (_isPersisted) Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isPersisted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Send your first message to start the conversation',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _discussion.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              widget.otherUser.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.otherUser.displayName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _discussion.messages.length,
                      itemBuilder: (context, index) {
                        final message = _discussion.messages[index];
                        final user = _discussion.getUser(message.senderId);
                        final isCurrentUser =
                            message.senderId == _currentUser!.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          child: Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: isCurrentUser
                                  ? () => _deleteMessage(message.id)
                                  : null,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user?.displayName ??
                                                message.senderId,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (isCurrentUser)
                                          GestureDetector(
                                            onTap: () =>
                                                _deleteMessage(message.id),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: Colors.red[400],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(message.content),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: _isPersisted
                            ? 'Type a message...'
                            : 'Send first message to start chat...',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    tooltip: 'Send Message',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
