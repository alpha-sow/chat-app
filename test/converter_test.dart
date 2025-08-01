import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_app_package/src/converter.dart';
import 'package:test/test.dart';

void main() {
  group('Converter Tests', () {
    test('should convert image file to base64 string and back using isolates', () async {
      // Create a test image file
      final testFile = File('/tmp/test_image.png');
      final testData = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
      ]); // PNG header
      await testFile.writeAsBytes(testData);

      // Convert to base64 string using isolate
      final base64String = await Converter.imageToBytes(testFile);
      expect(base64String, isA<String>());
      expect(base64String, equals(base64Encode(testData)));

      // Convert back to file using isolate
      final outputFile = await Converter.bytesToImage(
        base64String,
        '/tmp/output_image.png',
      );
      expect(await outputFile.exists(), isTrue);

      final outputData = await outputFile.readAsBytes();
      expect(outputData, equals(testData));

      // Cleanup
      await testFile.delete();
      await outputFile.delete();
    });

    test('should convert audio file to base64 string and back using isolates', () async {
      // Create a test audio file
      final testFile = File('/tmp/test_audio.wav');
      final testData = Uint8List.fromList([
        82,
        73,
        70,
        70,
      ]); // WAV header "RIFF"
      await testFile.writeAsBytes(testData);

      // Convert to base64 string using isolate
      final base64String = await Converter.audioToBytes(testFile);
      expect(base64String, isA<String>());
      expect(base64String, equals(base64Encode(testData)));

      // Convert back to file using isolate
      final outputFile = await Converter.bytesToAudio(
        base64String,
        '/tmp/output_audio.wav',
      );
      expect(await outputFile.exists(), isTrue);

      final outputData = await outputFile.readAsBytes();
      expect(outputData, equals(testData));

      // Cleanup
      await testFile.delete();
      await outputFile.delete();
    });

    test('should handle errors gracefully in isolates', () async {
      // Test with non-existent file
      final nonExistentFile = File('/tmp/non_existent_file.png');
      
      final result = await Converter.imageToBytes(nonExistentFile);
      expect(result, startsWith('Error:'));
    });
  });
}
