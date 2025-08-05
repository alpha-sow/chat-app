import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';

class UserAddPage extends StatefulWidget {
  const UserAddPage({super.key});

  @override
  State<UserAddPage> createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_displayNameController.text.trim().isEmpty) {
      context.showBanner(message: 'Name is required', type: AlertType.error);
      return;
    }

    if (_displayNameController.text.trim().length < 2) {
      context.showBanner(
        message: 'Name must be at least 2 characters',
        type: AlertType.error,
      );

      await UserService.instance().createUser(
        name: _displayNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      final phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
      if (!phoneRegExp.hasMatch(phone)) {
        context.showBanner(
          message: 'Please enter a valid phone number',
          type: AlertType.error,
        );

        return;
      }
    }

    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      final emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegExp.hasMatch(email)) {
        context.showBanner(
          message: 'Please enter a valid email address',
          type: AlertType.error,
        );

        return;
      }
    }

    try {
      final contact = User.create(
        name: _displayNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      await SyncService.instance().saveUser(contact);

      if (mounted) {
        context.showBanner(
          message: 'Contact "${contact.name}" added successfully',
          type: AlertType.success,
        );
        Navigator.of(context).pop(contact);
      }
    } on Exception catch (e) {
      logger.e('Error saving contact', error: e);
      if (mounted) {
        context.showBanner(
          message: 'Failed to add contact: $e',
          type: AlertType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsScaffold(
      appBar: AsAppBar(
        title: const Text('Add Contact'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          AsButton.ghost(
            onPressed: _saveContact,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Column(
            spacing: 10,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 50,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              AsTextField(
                controller: _displayNameController,
                label: 'Name *',
                hintText: 'Enter contact name',
              ),
              AsTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: 'Enter phone number (optional)',
              ),

              AsTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'Enter email address (optional)',
              ),

              const ASAlertBanner(
                message:
                    'Name is required. Email and phone are optional but '
                    'help identify contacts.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
