import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/contact_add_page.dart';
import 'package:chat_flutter_app/create_discussion_group_page.dart';
import 'package:chat_flutter_app/cubit/user_list_cubit.dart';
import 'package:chat_flutter_app/temp_chat_page.dart';
import 'package:chat_flutter_app/utils/utils.dart';
import 'package:chat_flutter_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscussionNewPage extends StatefulWidget {
  const DiscussionNewPage({required this.currentUser, super.key});

  final User currentUser;

  @override
  State<DiscussionNewPage> createState() => _DiscussionNewPageState();
}

class _DiscussionNewPageState extends State<DiscussionNewPage> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
  }

  Future<void> _addContact() async {
    await Navigator.of(context).push<User>(
      MaterialPageRoute(builder: (context) => const ContactAddPage()),
    );
  }

  Future<bool?> _showDeleteContactConfirmation(String contactName) {
    return context.showAlertDialog(
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
        Button.ghost(
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

  Future<void> _deleteContact(User user) async {
    try {
      logger.w('Deleting contact: ${user.displayName} (${user.id})');
      await SyncService.instance.deleteUser(user.id);

      if (mounted) {
        context.showBanner(
          message: 'Contact "${user.displayName}" deleted',
          type: AlertType.success,
        );
      }
    } on Exception catch (e) {
      logger.e('Error deleting contact', error: e);

      if (mounted) await context.read<UserListCubit>().loadUserList();

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
        builder: (context) => CreateDiscussionGroupPage(
          availableUsers: users,
          currentUser: _currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserListCubit()..loadUserList(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Discussion'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Button.ghost(
              onPressed: _addContact,
              child: const Icon(Icons.person_add),
            ),
          ],
        ),
        body: BlocBuilder<UserListCubit, UserListState>(
          builder: (context, state) {
            return switch (state) {
              UserListStateLoading() => const Center(
                child: LoadingCircular(),
              ),
              UserListStateLoaded(:final data) =>
                data.isEmpty
                    ? const Center(
                        child: Text(
                          'No contacts found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Button(
                              onPressed: () => _createGroupDiscussion(data),
                              child: const Text('New Group'),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: ListTileUI.divideTiles(
                                tiles: data.map(
                                  (user) => Dismissible(
                                    key: Key(user.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
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
                                    child: ListTileUI(
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
                              ).toList(),
                            ),
                          ),
                        ],
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
        builder: (context) => TempChatPage(
          discussion: tempDiscussion,
          currentUser: _currentUser,
          otherUser: user,
        ),
      ),
    );
  }
}
