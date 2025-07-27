import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tchat_app/tchat_app.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the application documents directory
  final Directory appDocDir = await getApplicationDocumentsDirectory();

  // Initialize the database with proper directory
  logger.i('Initializing database at: ${appDocDir.path}');
  await DatabaseService.initialize(directory: appDocDir.path);

  // Clear all existing data for fresh start (useful for development)
  logger.w('Clearing all database data for fresh start');
  await DatabaseService.instance.clearAllData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DiscussionListPage(),
    );
  }
}

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
        // Create sample users if none exist
        _availableUsers = [
          User.create(id: '1', name: 'John Doe', email: 'john@example.com'),
          User.create(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
          User.create(id: '3', name: 'Bob Wilson', email: 'bob@example.com'),
          User.create(id: '4', name: 'Alice Johnson', email: 'alice@example.com'),
        ];
        
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

  Future<void> _createNewDiscussion() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => CreateDiscussionPage(availableUsers: _availableUsers),
      ),
    );

    if (result != null) {
      final title = result['title'] as String;
      final selectedUsers = result['users'] as List<User>;
      
      // Create new discussion
      logger.i('Creating new discussion: $title with ${selectedUsers.length} users');
      final discussion = Discussion.withUsers(
        title: title,
        users: selectedUsers,
        persistToDatabase: true,
      );

      // Add welcome message
      if (selectedUsers.isNotEmpty) {
        discussion.addMessage(
          selectedUsers.first.id,
          'Welcome to $title! 👋',
        );
        logger.d('Added welcome message to discussion: ${discussion.id}');
      }

      // Refresh the list
      await _loadData();
    }
  }

  Future<void> _deleteDiscussion(DiscussionState discussion) async {
    final shouldDelete = await _showDeleteDiscussionConfirmation(discussion.title);
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
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
                      '💡 Tip: Once you have discussions, you can:\n• Tap to open chat\n• Long press to delete\n• Swipe left to delete\n• Tap delete icon',
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
          : ListView.builder(
              itemCount: _discussions.length,
              itemBuilder: (context, index) {
                final discussion = _discussions[index];
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
                      return await _showDeleteDiscussionConfirmation(discussion.title);
                    },
                    onDismissed: (direction) async {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDiscussion,
        tooltip: 'Create New Discussion',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CreateDiscussionPage extends StatefulWidget {
  final List<User> availableUsers;

  const CreateDiscussionPage({super.key, required this.availableUsers});

  @override
  State<CreateDiscussionPage> createState() => _CreateDiscussionPageState();
}

class _CreateDiscussionPageState extends State<CreateDiscussionPage> {
  final _titleController = TextEditingController();
  final Set<User> _selectedUsers = {};

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createDiscussion() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a discussion title')),
      );
      return;
    }

    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'users': _selectedUsers.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Discussion'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _createDiscussion,
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Discussion Title',
                border: OutlineInputBorder(),
                hintText: 'Enter a title for your discussion',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Participants',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.availableUsers.length,
                itemBuilder: (context, index) {
                  final user = widget.availableUsers[index];
                  final isSelected = _selectedUsers.contains(user);
                  
                  return Card(
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedUsers.add(user);
                          } else {
                            _selectedUsers.remove(user);
                          }
                        });
                      },
                      title: Text(user.displayName),
                      subtitle: Text(user.email ?? 'No email'),
                      secondary: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedUsers.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Participants (${_selectedUsers.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _selectedUsers.map((user) {
                        return Chip(
                          label: Text(user.displayName),
                          onDeleted: () {
                            setState(() {
                              _selectedUsers.remove(user);
                            });
                          },
                        );
                      }).toList(),
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

class ChatPage extends StatefulWidget {
  final String discussionId;
  final String currentUserId;

  const ChatPage({
    super.key,
    required this.discussionId,
    required this.currentUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Discussion? _discussion;
  final TextEditingController _messageController = TextEditingController();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user
      _currentUser = await DatabaseService.instance.getUser(widget.currentUserId);
      
      // Load the discussion
      _discussion = await Discussion.loadFromDatabase(widget.discussionId);
    } catch (e) {
      logger.e('Error loading chat', error: e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _discussion?.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _discussion != null && _currentUser != null) {
      setState(() {
        _discussion!.addMessage(_currentUser!.id, text);
        _messageController.clear();
      });
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    if (_discussion != null && _currentUser != null) {
      // Show confirmation dialog
      final shouldDelete = await _showDeleteConfirmation();
      if (shouldDelete == true) {
        setState(() {
          _discussion!.deleteMessage(messageId, _currentUser!.id);
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
    if (_isLoading || _currentUser == null || _discussion == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_discussion!.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Discussion: ${_discussion?.title ?? 'Loading...'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current User: ${_currentUser!.displayName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Messages: ${_discussion?.messages.length ?? 0} (Persisted)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _discussion?.messages.length ?? 0,
                itemBuilder: (context, index) {
                  final message = _discussion!.messages[index];
                  final user = _discussion!.getUser(message.senderId);
                  final isCurrentUser = message.senderId == _currentUser!.id;

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
                          constraints: const BoxConstraints(maxWidth: 280),
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
                                      user?.displayName ?? message.senderId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (isCurrentUser)
                                    GestureDetector(
                                      onTap: () => _deleteMessage(message.id),
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'Long press to delete',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
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
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
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
