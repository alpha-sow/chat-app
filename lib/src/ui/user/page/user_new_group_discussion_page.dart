import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:flutter/material.dart';

class UserNewGroupDiscussionPage extends StatefulWidget {
  const UserNewGroupDiscussionPage({
    required this.availableUsers,
    required this.currentUser,
    super.key,
  });

  final List<User> availableUsers;
  final User currentUser;

  @override
  State<UserNewGroupDiscussionPage> createState() =>
      _UserNewGroupDiscussionPageState();
}

class _UserNewGroupDiscussionPageState
    extends State<UserNewGroupDiscussionPage> {
  final _titleController = TextEditingController();
  late User _currentUser;
  final Set<User> _selectedUsers = {};
  bool _isCustomTitle = false;

  @override
  void initState() {
    super.initState();

    _currentUser = widget.currentUser;
    _selectedUsers.add(_currentUser);
    _updateTitle();

    _titleController.addListener(() {
      if (!_isCustomTitle) {
        final expectedTitle = _generateDefaultTitle(_selectedUsers);
        if (_titleController.text != expectedTitle &&
            _titleController.text.isNotEmpty) {
          setState(() {
            _isCustomTitle = true;
          });
          logger.d('User created custom title: ${_titleController.text}');
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _generateRandomGroupName() {
    final adjectives = [
      faker.lorem.word(),
      faker.color.commonColor(),
      faker.animal.name(),
    ];
    final nouns = [
      'Squad',
      'Team',
      'Group',
      'Circle',
      'Crew',
      'Gang',
      'Club',
      'Alliance',
      'Collective',
      'Network',
    ];

    final adjective =
        adjectives[faker.randomGenerator.integer(adjectives.length)];
    final noun = nouns[faker.randomGenerator.integer(nouns.length)];

    return '${adjective.substring(0, 1).toUpperCase()}'
        '${adjective.substring(1)} $noun';
  }

  String _generateDefaultTitle(Set<User> users) {
    if (users.isEmpty) return '';

    final otherUsers = users
        .where((user) => user.id != widget.currentUser.id)
        .toSet();

    if (otherUsers.isEmpty) {
      return 'Personal Notes';
    }

    final names = otherUsers.map((user) => user.displayName).toList()..sort();

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
      final defaultTitle = _generateRandomGroupName();
      _titleController.text = defaultTitle;
      logger.d('Generated random group title: $defaultTitle');
    }
  }

  Future<void> _createDiscussion() async {
    final title = _titleController.text.trim();

    if (title.isEmpty && _selectedUsers.isNotEmpty) {
      _updateTitle();
    }

    if (title.isEmpty) {
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
      context.showBanner(
        message: 'Please select at least one other participant',
        type: AlertType.error,
      );
      return;
    }

    logger.i(
      'Creating discussion: ${_titleController.text.trim()} '
      '(${_isCustomTitle ? "custom" : "auto-generated"})',
    );

    final discussion = await DiscussionService.instance().withUsers(
      title: title,
      users: _selectedUsers.toList(),
      type: DiscussionType.group,
    );

    final welcomeMessages = [
      'Welcome to $title! 👋',
      'Hello everyone! 🎉 Welcome to $title',
      'Great to have you all here in $title! ✨',
      'Welcome to our new discussion: $title 🚀',
      'Hey team! Welcome to $title 💬',
      '${faker.lorem.sentence()} Welcome to $title!',
    ];

    final welcomeMessage = faker.randomGenerator.element(welcomeMessages);
    logger.d('Added welcome message to discussion: ${discussion.id}');

    await MessageService.instance().sendMessage(
      discussionId: discussion.id,
      senderId: _currentUser.id,
      content: welcomeMessage,
    );

    if (mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => MessagePage(
            discussion: discussion,
            currentUser: _currentUser,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsScaffold(
      appBar: AsAppBar(
        title: const Text('Create Group Discussion'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          AsButton.ghost(
            onPressed: _createDiscussion,
            child: const Text(
              'Create',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AsTextField(
                    controller: _titleController,
                    label: 'Discussion Title',
                    hintText: _selectedUsers.isEmpty
                        ? 'Enter a title for your discussion'
                        : 'Auto-generated from participants',
                  ),
                ),
                const SizedBox(width: 8),
                AsButton.outlined(
                  onPressed: () {
                    final randomName = _generateRandomGroupName();
                    setState(() {
                      _titleController.text = randomName;
                      _isCustomTitle = true;
                    });
                    logger.d('Generated random group name: $randomName');
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.casino, size: 16),
                      SizedBox(width: 4),
                      Text('Random'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                  spacing: 8,
                  children: [
                    Text(
                      'Selected Participants (${_selectedUsers.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedUsers.map((user) {
                        final isCurrentUser = user.id == widget.currentUser.id;
                        return _ParticipantCard(
                          user: user,
                          isCurrentUser: isCurrentUser,
                          onRemove: isCurrentUser
                              ? null
                              : () {
                                  setState(() {
                                    _selectedUsers.remove(user);
                                    _updateTitle();
                                  });
                                },
                        );
                      }).toList(),
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
            Column(
              children: AsListTile.divideTiles(
                tiles: widget.availableUsers.map((user) {
                  final isSelected = _selectedUsers.contains(user);
                  final isCurrentUser = user.id == widget.currentUser.id;

                  return AsListTile(
                    onTap: isCurrentUser
                        ? null
                        : () {
                            setState(() {
                              if (isSelected) {
                                _selectedUsers.remove(user);
                              } else {
                                _selectedUsers.add(user);
                              }
                              _updateTitle();
                            });
                          },
                    leading: CircleAvatar(
                      backgroundColor: isCurrentUser
                          ? Colors.green[100]
                          : Colors.blue[100],
                      backgroundImage: user.avatarUrl != null
                          ? CachedNetworkImageProvider(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.initials,
                              style: TextStyle(
                                color: isCurrentUser
                                    ? Colors.green[800]
                                    : Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
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
                    trailing: isSelected
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.radio_button_unchecked),
                  );
                }),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.user,
    required this.isCurrentUser,
    this.onRemove,
  });

  final User user;
  final bool isCurrentUser;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentUser ? Colors.green[300]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AsAvatar(
            radius: 12,
            backgroundColor: isCurrentUser
                ? Colors.green[100]
                : Colors.blue[100],
            backgroundImage: user.avatarUrl != null
                ? CachedNetworkImageProvider(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser
                          ? Colors.green[800]
                          : Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isCurrentUser ? Colors.green[800] : Colors.grey[800],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 4),
            Text(
              '(You)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
