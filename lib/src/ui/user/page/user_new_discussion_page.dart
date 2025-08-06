import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserNewDiscussionPage extends StatelessWidget {
  const UserNewDiscussionPage({required this.currentUser, super.key});

  final User currentUser;

  Future<void> _addContact(BuildContext context) async {
    await Navigator.of(context).push<User>(
      MaterialPageRoute(builder: (context) => const UserAddPage()),
    );
  }

  Future<bool?> _showDeleteContactConfirmation({
    required String contactName,
    required BuildContext context,
  }) {
    return context.showAsActionBottomSheet(
      title: const Text('Delete Contact'),
      actions: [
        AsDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
        const AsDialogAction(
          isDestructiveAction: true,
          onPressed: null,
          child: Text('Delete and Block'),
        ),
      ],
      cancelAction: AsDialogAction(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
    );
  }

  Future<void> _deleteContact({
    required BuildContext context,
    required User user,
  }) async {
    try {
      logger.w('Deleting contact: ${user.displayName} (${user.id})');
      await UserService.instance().deleteUser(user.id);

      if (context.mounted) {
        context.showBanner(
          message: 'Contact "${user.displayName}" deleted',
          type: AlertType.success,
        );
      }
    } on Exception catch (e) {
      logger.e('Error deleting contact', error: e);

      if (context.mounted) {
        context.showBanner(
          message: 'Failed to delete contact: $e',
          type: AlertType.error,
        );
      }
    }
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
                        children: AsListTile.divideTiles(
                          tiles: [
                            AsListTile(
                              title: const Text('Add Contact'),
                              onTap: () => _addContact(context),
                              leading: AsAvatar.icon(icon: Icons.person_add),
                            ),
                            AsListTile(
                              leading: AsAvatar.icon(icon: Icons.group),
                              title: const Text('New Group'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        UserNewGroupDiscussionPage(
                                          availableUsers: data,
                                          currentUser: currentUser,
                                        ),
                                  ),
                                );
                              },
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
                                    contactName: user.displayName,
                                    context: context,
                                  );
                                },
                                onDismissed: (direction) async {
                                  await _deleteContact(
                                    user: user,
                                    context: context,
                                  );
                                },
                                child: AsListTile(
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
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (context) => MessageTempPage(
                                          discussion:
                                              DiscussionService.instance()
                                                  .tempWithUsers(
                                                    title: '',
                                                    users: [currentUser, user],
                                                  ),
                                          currentUser: currentUser,
                                          otherUser: user,
                                        ),
                                      ),
                                    );
                                  },
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
}
