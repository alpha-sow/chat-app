import 'dart:io';

import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatTempPage extends StatefulWidget {
  const ChatTempPage({
    required this.discussion,
    required this.currentUser,
    required this.otherUser,
    super.key,
  });
  final DiscussionService discussion;
  final User currentUser;
  final User otherUser;

  @override
  State<ChatTempPage> createState() => _ChatTempPageState();
}

class _ChatTempPageState extends State<ChatTempPage> {
  late DiscussionService _discussion;
  final TextEditingController _messageController = TextEditingController();
  late User _currentUser;
  late User _otherUser;
  XFile? _selectedImage;
  String? _recordedAudioPath;

  @override
  void initState() {
    super.initState();
    _discussion = widget.discussion;
    _currentUser = widget.currentUser;
    _otherUser = widget.otherUser;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _discussion.dispose();
    super.dispose();
  }

  Future<void> _onImageSelected(XFile image) async {
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _onAudioRecorded(String audioPath) async {
    setState(() {
      _recordedAudioPath = audioPath;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedImage == null && _recordedAudioPath == null) {
      return;
    }

    final discussion = DiscussionService.withUsers(
      id: _discussion.id,
      title: _discussion.title,
      users: [_currentUser, _otherUser],
      persistToDatabase: true,
    );

    logger.i('Discussion persisted to database: ${discussion.id}');

    if (text.isNotEmpty) {
      discussion.sendMessage(
        _currentUser.id,
        text,
      );
    }

    if (_selectedImage != null) {
      try {
        final imageFile = File(_selectedImage!.path);
        final downloadUrl = await StorageService.instance.uploadChatImage(
          file: imageFile,
          userId: _currentUser.id,
          discussionId: widget.discussion.id,
        );

        discussion.sendMessage(
          _currentUser.id,
          downloadUrl,
          type: MessageType.image,
        );
      } on Exception catch (e) {
        logger.e('Error uploading image', error: e);

        discussion.sendMessage(
          _currentUser.id,
          _selectedImage!.path,
          type: MessageType.image,
        );
      }
    }

    if (_recordedAudioPath != null) {
      try {
        final audioFile = File(_recordedAudioPath!);
        final downloadUrl = await StorageService.instance.uploadChatAudio(
          file: audioFile,
          userId: _currentUser.id,
          discussionId: widget.discussion.id,
        );

        discussion.sendMessage(
          _currentUser.id,
          downloadUrl,
          type: MessageType.audio,
        );
      } on Exception catch (e) {
        logger.e('Error uploading audio', error: e);

        discussion.sendMessage(
          _currentUser.id,
          _recordedAudioPath!,
          type: MessageType.audio,
        );
      }
    }

    if (mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ChatPage(
            discussion: discussion.state,
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.otherUser.displayName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: ASAlertBanner(
                message: 'Send your first message to start the conversation',
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: widget.otherUser.avatarUrl != null
                          ? CachedNetworkImageProvider(
                              widget.otherUser.avatarUrl!,
                            )
                          : null,
                      child: widget.otherUser.avatarUrl == null
                          ? Text(
                              widget.otherUser.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.otherUser.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a conversation',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            MessageInput(
              messageController: _messageController,
              onSendMessage: (message) {
                _sendMessage();
                _messageController.clear();
              },
              onImageSelected: _onImageSelected,
              onAudioRecorded: _onAudioRecorded,
              selectedImage: _selectedImage,
              recordedAudioPath: _recordedAudioPath,
              onRemoveImage: () => setState(() {
                _selectedImage = null;
              }),
              onRemoveAudio: () => setState(() {
                _recordedAudioPath = null;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
