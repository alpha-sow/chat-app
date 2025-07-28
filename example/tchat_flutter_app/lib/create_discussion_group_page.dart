import 'package:flutter/material.dart';
import 'package:tchat_app/tchat_app.dart';

import 'utils/utils.dart';

class CreateDiscussionGroupPage extends StatefulWidget {
  final List<User> availableUsers;
  final User currentUser;

  const CreateDiscussionGroupPage({
    super.key,
    required this.availableUsers,
    required this.currentUser,
  });

  @override
  State<CreateDiscussionGroupPage> createState() =>
      _CreateDiscussionGroupPageState();
}

class _CreateDiscussionGroupPageState extends State<CreateDiscussionGroupPage> {
  final _titleController = TextEditingController();
  final Set<User> _selectedUsers = {};
  bool _isCustomTitle = false;

  @override
  void initState() {
    super.initState();
    // Automatically include current user
    _selectedUsers.add(widget.currentUser);
    _updateTitle();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _generateDefaultTitle(Set<User> users) {
    if (users.isEmpty) return '';

    // Exclude current user from title (since "you" are already in the conversation)
    final otherUsers = users
        .where((user) => user.id != widget.currentUser.id)
        .toSet();

    if (otherUsers.isEmpty) {
      return 'Personal Notes'; // Just current user selected
    }

    final names = otherUsers.map((user) => user.displayName).toList();
    names.sort(); // Sort for consistent ordering

    if (names.length == 1) {
      return 'Chat with ${names[0]}';
    } else if (names.length == 2) {
      return '${names[0]} & ${names[1]}';
    } else if (names.length == 3) {
      return '${names[0]}, ${names[1]} & ${names[2]}';
    } else if (names.length <= 5) {
      final firstNames = names.take(names.length - 1).join(', ');
      return '$firstNames & ${names.last}';
    } else {
      final firstNames = names.take(3).join(', ');
      return '$firstNames & ${names.length - 3} others';
    }
  }

  void _updateTitle() {
    if (!_isCustomTitle && _selectedUsers.isNotEmpty) {
      final defaultTitle = _generateDefaultTitle(_selectedUsers);
      _titleController.text = defaultTitle;
      logger.d('Generated default title: $defaultTitle');
    }
  }

  void _createDiscussion() {
    // Auto-generate title if empty and users are selected
    if (_titleController.text.trim().isEmpty && _selectedUsers.isNotEmpty) {
      _updateTitle();
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a discussion title or select participants',
          ),
        ),
      );
      return;
    }

    if (_selectedUsers.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one other participant'),
        ),
      );
      return;
    }

    logger.i(
      'Creating discussion: ${_titleController.text.trim()} (${_isCustomTitle ? "custom" : "auto-generated"})',
    );
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
              decoration: InputDecoration(
                labelText: 'Discussion Title',
                border: const OutlineInputBorder(),
                hintText: _selectedUsers.isEmpty
                    ? 'Enter a title for your discussion'
                    : 'Auto-generated from participants',
                suffixIcon: _isCustomTitle
                    ? IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            _isCustomTitle = false;
                            _updateTitle();
                          });
                        },
                        tooltip: 'Reset to auto-generated title',
                      )
                    : null,
              ),
              onChanged: (value) {
                // Mark as custom title if user manually types
                if (!_isCustomTitle) {
                  final expectedTitle = _generateDefaultTitle(_selectedUsers);
                  if (value != expectedTitle && value.isNotEmpty) {
                    setState(() {
                      _isCustomTitle = true;
                    });
                    logger.d('User created custom title: $value');
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            if (_selectedUsers.isNotEmpty && !_isCustomTitle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-generated title',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (_isCustomTitle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Custom title',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                  final isCurrentUser = user.id == widget.currentUser.id;

                  return Card(
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: isCurrentUser
                          ? null
                          : (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedUsers.add(user);
                                } else {
                                  _selectedUsers.remove(user);
                                }
                                _updateTitle();
                              });
                            },
                      title: Row(
                        children: [
                          Expanded(child: Text(user.displayName)),
                          if (isCurrentUser)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green[300]!),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        isCurrentUser
                            ? '${user.email ?? 'No email'} • Always included'
                            : user.email ?? 'No email',
                      ),
                      secondary: CircleAvatar(
                        backgroundColor: isCurrentUser
                            ? Colors.green[100]
                            : Colors.blue[100],
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            color: isCurrentUser
                                ? Colors.green[800]
                                : Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
