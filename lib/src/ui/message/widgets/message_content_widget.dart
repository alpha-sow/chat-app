import 'dart:io';

import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter/material.dart';

class MessageContentWidget extends StatelessWidget {
  const MessageContentWidget({
    required this.message,
    super.key,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return _ImageMessageWidget(imagePath: message.content);
      case MessageType.audio:
        return _AudioMessageWidget(audioPath: message.content);
      case MessageType.text:
      case MessageType.file:
      case MessageType.video:
        return Text(
          message.content,
          style: TextStyle(color: Theme.of(context).primaryColor),
        );
    }
  }
}

class _ImageMessageWidget extends StatelessWidget {
  const _ImageMessageWidget({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _isUrl(imagePath)
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          'Image not found',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          'Image not found',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
}

class _AudioMessageWidget extends StatelessWidget {
  const _AudioMessageWidget({required this.audioPath});

  final String audioPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.audiotrack, color: Colors.blue[600]),
          const SizedBox(width: 8),
          const Text('Audio message'),
        ],
      ),
    );
  }
}
