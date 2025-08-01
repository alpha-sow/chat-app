import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

class Converter {
  static Future<String> imageToBytes(File imageFile) async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _imageToIsolateWorker,
      {
        'sendPort': receivePort.sendPort,
        'filePath': imageFile.path,
      },
    );
    
    final result = await receivePort.first as String;
    return result;
  }

  static Future<File> bytesToImage(String base64String, String filePath) async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _bytesToImageIsolateWorker,
      {
        'sendPort': receivePort.sendPort,
        'base64String': base64String,
        'filePath': filePath,
      },
    );
    
    final result = await receivePort.first as String;
    return File(result);
  }

  static Future<String> audioToBytes(File audioFile) async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _audioToIsolateWorker,
      {
        'sendPort': receivePort.sendPort,
        'filePath': audioFile.path,
      },
    );
    
    final result = await receivePort.first as String;
    return result;
  }

  static Future<File> bytesToAudio(String base64String, String filePath) async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _bytesToAudioIsolateWorker,
      {
        'sendPort': receivePort.sendPort,
        'base64String': base64String,
        'filePath': filePath,
      },
    );
    
    final result = await receivePort.first as String;
    return File(result);
  }
}

Future<void> _imageToIsolateWorker(Map<String, dynamic> params) async {
  final sendPort = params['sendPort'] as SendPort;
  final filePath = params['filePath'] as String;
  
  try {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    sendPort.send(base64String);
  } on Exception catch (e) {
    sendPort.send('Error: $e');
  }
}

Future<void> _bytesToImageIsolateWorker(Map<String, dynamic> params) async {
  final sendPort = params['sendPort'] as SendPort;
  final base64String = params['base64String'] as String;
  final filePath = params['filePath'] as String;
  
  try {
    final bytes = base64Decode(base64String);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    sendPort.send(filePath);
  } on Exception catch (e) {
    sendPort.send('Error: $e');
  }
}

Future<void> _audioToIsolateWorker(Map<String, dynamic> params) async {
  final sendPort = params['sendPort'] as SendPort;
  final filePath = params['filePath'] as String;
  
  try {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    sendPort.send(base64String);
  } on Exception catch (e) {
    sendPort.send('Error: $e');
  }
}

Future<void> _bytesToAudioIsolateWorker(Map<String, dynamic> params) async {
  final sendPort = params['sendPort'] as SendPort;
  final base64String = params['base64String'] as String;
  final filePath = params['filePath'] as String;
  
  try {
    final bytes = base64Decode(base64String);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    sendPort.send(filePath);
  } on Exception catch (e) {
    sendPort.send('Error: $e');
  }
}
