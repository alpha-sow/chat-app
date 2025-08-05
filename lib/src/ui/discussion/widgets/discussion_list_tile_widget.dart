import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscussionListTileWidget extends StatelessWidget {
  const DiscussionListTileWidget({
    required this.discussion,
    required this.currentUser,
    super.key,
  });

  final User currentUser;
  final Discussion discussion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscussionUserCubit(
        discussion.participants.firstWhere(
          (id) => id != currentUser.id,
        ),
      ),
      child: BlocBuilder<DiscussionUserCubit, DiscussionUserState>(
        builder: (context, withUserState) {
          return switch (withUserState) {
            DiscussionUserStateLoading() => const SizedBox.shrink(),
            DiscussionUserStateLoaded(:final user) => DiscussionLoadedTile(
              discussion: discussion,
              currentUser: currentUser,
              user: user,
            ),
            DiscussionUserStateError() => const DiscussionErrorTile(
              errorMessage: 'Error loading user',
            ),
          };
        },
      ),
    );
  }
}
