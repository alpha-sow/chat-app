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
    this.focusNode,
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
  final FocusNode? focusNode;
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
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
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
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
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
    await context.showAsActionBottomSheet<void>(
      title: const Text('Select Image Source'),
      actions: [
        AsDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
            _pickImage();
          },
          child: const Text('Gallery'),
        ),
        AsDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
            _takePicture();
          },
          child: const Text('Camera'),
        ),
      ],
      cancelAction: AsDialogAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
          if (widget.selectedImage == null && widget.recordedAudioPath == null)
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: AsTextField(
                    controller: widget.messageController,
                    focusNode: _focusNode,
                    hintText: 'Send first message to start chat...',
                    onSubmitted: (value) => widget.onSendMessage?.call(value),
                  ),
                ),
                ListenableBuilder(
                  listenable: widget.messageController,
                  builder: (context, state) {
                    if (widget.messageController.text.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      spacing: 16,
                      children: [
                        AsIconButton.ghost(
                          onPressed: _showImageSourceSelection,
                          icon: Icons.image,
                        ),
                        AnimatedBuilder(
                          animation: _recordingAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isRecording
                                  ? _recordingAnimation.value
                                  : 1.0,
                              child: AsIconButton.ghost(
                                iconColor: _isRecording ? Colors.red : null,
                                onPressed: _toggleRecording,
                                icon: _isRecording ? Icons.stop : Icons.mic,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                ListenableBuilder(
                  listenable: widget.messageController,
                  builder: (context, state) {
                    if (widget.messageController.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return AsIconButton.ghost(
                      onPressed: () {
                        widget.onSendMessage?.call(
                          widget.messageController.text,
                        );
                      },
                      icon: Icons.send,
                    );
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: AsButton(
                    isLoading: widget.isSending,
                    child: const Text('Send'),
                    onPressed: () {
                      widget.onSendMessage?.call(
                        widget.messageController.text,
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
