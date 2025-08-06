import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscussionTile extends StatefulWidget {
  const DiscussionTile({
    required this.currentUserId,
    required this.discussion,
    required this.onTap,
    super.key,
  });

  final String currentUserId;
  final Discussion discussion;
  final ValueChanged<Discussion> onTap;

  @override
  State<DiscussionTile> createState() => _DiscussionTileState();
}

class _DiscussionTileState extends State<DiscussionTile> {
  late String _withUserId;

  @override
  void initState() {
    _withUserId = widget.discussion.participants.firstWhere(
      (id) => id != widget.currentUserId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscussionUserCubit(_withUserId),
      child: BlocBuilder<DiscussionUserCubit, DiscussionUserState>(
        builder: (context, withUserState) {
          return switch (withUserState) {
            DiscussionUserStateLoading() => const SizedBox.shrink(),
            DiscussionUserStateLoaded(:final user) => AsListTile(
              leading: CircleAvatar(
                child: Text(
                  widget.discussion.type == DiscussionType.group
                      ? widget.discussion.title[0].toUpperCase()
                      : (user.displayName[0].toUpperCase()),
                ),
              ),
              title: Text(
                widget.discussion.type == DiscussionType.group
                    ? widget.discussion.title
                    : user.displayName,
              ),
              subtitle: LastMessageSubtitle(
                message: widget.discussion.lastMessage,
              ),
              trailing: Icon(Icons.adaptive.arrow_forward),
              onTap: () => widget.onTap(widget.discussion),
            ),
            DiscussionUserStateError() => AsListTile(
              leading: const Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
              title: const Text('Error loading discussion'),
              subtitle: const Text(
                'Error loading user',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              onTap: () => widget.onTap(widget.discussion),
            ),
          };
        },
      ),
    );
  }
}
