import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:flutter/material.dart';

class DiscussionErrorTile extends StatelessWidget {
  const DiscussionErrorTile({
    required this.errorMessage,
    this.onRetry,
    super.key,
  });

  final String errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AsListTile(
      leading: const Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
      title: const Text('Error loading discussion'),
      subtitle: Text(
        errorMessage,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: onRetry != null
          ? IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
            )
          : null,
    );
  }
}
