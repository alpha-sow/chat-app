import 'dart:async';
import 'dart:io';

import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    required this.messageController,
    super.key,
    this.onSendMessage,
    this.onImageSelected,
    this.onAudioRecorded,
    this.selectedImage,
    this.recordedAudioPath,
    this.onRemoveImage,
    this.onRemoveAudio,
    this.isSending = false,
  });

  final TextEditingController messageController;
  final ValueChanged<String>? onSendMessage;
  final ValueChanged<XFile>? onImageSelected;
  final ValueChanged<String>? onAudioRecorded;
  final XFile? selectedImage;
  final String? recordedAudioPath;
  final VoidCallback? onRemoveImage;
  final VoidCallback? onRemoveAudio;
  final bool isSending;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;

  @override
  void initState() {
    super.initState();
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _recordingAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.2,
        ).animate(
          CurvedAnimation(
            parent: _recordingAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _recordingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      widget.onImageSelected?.call(image);
    }
  }

  Future<void> _takePicture() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      widget.onImageSelected?.call(image);
    }
  }

  void _removeSelectedImage() {
    widget.onRemoveImage?.call();
  }

  Future<void> _showImageSourceSelection() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        widget.onAudioRecorded?.call(path);
      }
      _recordingAnimationController
        ..stop()
        ..reset();
      setState(() {
        _isRecording = false;
      });
    } else {
      if (await _recorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final audioPath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          const RecordConfig(),
          path: audioPath,
        );
        unawaited(_recordingAnimationController.repeat(reverse: true));
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecording)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _recordingAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        transform: Matrix4.identity()
                          ..scale(_recordingAnimation.value),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recording audio...',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tap to stop',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(widget.selectedImage!.path),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.selectedImage!.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _removeSelectedImage,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          if (widget.recordedAudioPath != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.audiotrack, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Audio recorded',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onRemoveAudio,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Row(
            spacing: 8,
            children: [
              AsButton.ghost(
                onPressed: _showImageSourceSelection,
                child: const Icon(Icons.image),
              ),
              AnimatedBuilder(
                animation: _recordingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _recordingAnimation.value : 1.0,
                    child: AsButton.ghost(
                      onPressed: _toggleRecording,
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: _isRecording ? Colors.red : null,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: AsTextField(
                  controller: widget.messageController,
                  hintText: 'Send first message to start chat...',
                  onSubmitted: (value) => widget.onSendMessage?.call(value),
                ),
              ),
              AsButton.ghost(
                onPressed: widget.isSending
                    ? null
                    : () {
                        widget.onSendMessage?.call(
                          widget.messageController.text,
                        );
                      },
                child: widget.isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: AsLoadingCircular(),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
