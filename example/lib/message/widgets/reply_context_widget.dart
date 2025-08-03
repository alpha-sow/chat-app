import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/message/message.dart';
import 'package:flutter/material.dart';

class ReplyContextWidget extends StatefulWidget {
  const ReplyContextWidget({
    required this.replyToMessageId,
    super.key,
  });

  final String replyToMessageId;

  @override
  State<ReplyContextWidget> createState() => _ReplyContextWidgetState();
}

class _ReplyContextWidgetState extends State<ReplyContextWidget> {
  late String _replyToMessageId;
  bool _isLoading = true;
  Message? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _replyToMessageId = widget.replyToMessageId;
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    try {
      final replyToMessage = await MessageService.instance.getMessage(
        _replyToMessageId,
      );
      if (replyToMessage != null) {
        setState(() {
          _replyToMessage = replyToMessage;
        });
      }
    } on Exception catch (e) {
      logger.e('Error loading reply message', error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_replyToMessage == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: Colors.blue[300]!, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replying to '
            '${_replyToMessage!.senderId}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 2),
          MessageContentWidget(message: _replyToMessage!),
        ],
      ),
    );
  }
}
