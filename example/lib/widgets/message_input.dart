import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    required this.messageController,
    super.key,
    this.onSendMessage,
    this.onImageSelected,
    this.onAudioRecorded,
  });

  final TextEditingController messageController;
  final ValueChanged<String>? onSendMessage;
  final ValueChanged<XFile>? onImageSelected;
  final ValueChanged<String>? onAudioRecorded;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

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
      setState(() {
        _isRecording = false;
      });
    } else {
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(),
          path: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );
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
      child: Row(
        spacing: 8,
        children: [
          ASButton.ghost(
            onPressed: _showImageSourceSelection,
            child: const Icon(Icons.image),
          ),
          ASButton.ghost(
            onPressed: _toggleRecording,
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : null,
            ),
          ),
          Expanded(
            child: ASTextField(
              controller: widget.messageController,
              hintText: 'Send first message to start chat...',
              onSubmitted: (value) => widget.onSendMessage?.call(value),
            ),
          ),
          ASButton.ghost(
            onPressed: () => widget.onSendMessage?.call(widget.messageController.text),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
