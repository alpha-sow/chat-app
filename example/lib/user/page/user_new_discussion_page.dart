import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/chat/chat.dart';
import 'package:chat_flutter_app/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserNewDiscussionPage extends StatefulWidget {
  const UserNewDiscussionPage({required this.currentUser, super.key});

  final User currentUser;

  @override
  State<UserNewDiscussionPage> createState() => _UserNewDiscussionPageState();
}

class _UserNewDiscussionPageState extends State<UserNewDiscussionPage> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
  }

  Future<void> _addContact() async {
    await Navigator.of(context).push<User>(
      MaterialPageRoute(builder: (context) => const UserAddPage()),
    );
  }

  Future<bool?> _showDeleteContactConfirmation(String contactName) {
    return context.showASAlertDialog(
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

  Future<void> _deleteContact(User user) async {
    try {
      logger.w('Deleting contact: ${user.displayName} (${user.id})');
      await UserService.instance.deleteUser(user.id);

      if (mounted) {
        context.showBanner(
          message: 'Contact "${user.displayName}" deleted',
          type: AlertType.success,
        );
      }
    } on Exception catch (e) {
      logger.e('Error deleting contact', error: e);

      if (mounted) {
        context.showBanner(
          message: 'Failed to delete contact: $e',
          type: AlertType.error,
        );
      }
    }
  }

  Future<void> _createGroupDiscussion(List<User> users) async {
    await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => UserNewGroupDiscussionPage(
          availableUsers: users,
          currentUser: _currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserListCubit(),
      child: AsScaffold(
        appBar: AsAppBar(
          title: const Text('New Discussion'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: BlocBuilder<UserListCubit, UserListState>(
          builder: (context, state) {
            return switch (state) {
              UserListStateLoading() => const Center(
                child: AsLoadingCircular(),
              ),
              UserListStateLoaded(:final data) =>
                data.isEmpty
                    ? const Center(
                        child: Text(
                          'No contacts found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView(
                        children: ASListTile.divideTiles(
                          tiles: [
                            ASListTile(
                              title: const Text('Add Contact'),
                              onTap: _addContact,
                              leading: AsAvatar.icon(icon: Icons.person_add),
                            ),
                            ASListTile(
                              leading: AsAvatar.icon(icon: Icons.group),
                              title: const Text('New Group'),
                              onTap: () => _createGroupDiscussion(data),
                            ),
                            ...data.map(
                              (user) => Dismissible(
                                key: Key(user.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                    right: 20,
                                  ),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return _showDeleteContactConfirmation(
                                    user.displayName,
                                  );
                                },
                                onDismissed: (direction) async {
                                  await _deleteContact(user);
                                },
                                child: ASListTile(
                                  leading: UserAvatar(user),
                                  title: Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle:
                                      user.email != null &&
                                          user.email!.isNotEmpty
                                      ? Text(user.email!)
                                      : user.phoneNumber != null &&
                                            user.phoneNumber!.isNotEmpty
                                      ? Text(user.phoneNumber!)
                                      : null,
                                  onTap: () => _starChatWithUser(user),
                                ),
                              ),
                            ),
                          ],
                        ).toList(),
                      ),

              UserListStateError(:final e) => Center(child: Text('$e')),
            };
          },
        ),
      ),
    );
  }

  Future<void> _starChatWithUser(User user) async {
    final tempDiscussion = DiscussionService.withUsers(
      title: user.displayName,
      users: [_currentUser, user],
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChatTempPage(
          discussion: tempDiscussion,
          currentUser: _currentUser,
          otherUser: user,
        ),
      ),
    );
  }
}
