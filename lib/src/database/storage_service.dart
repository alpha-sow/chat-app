import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

enum StorageFolder {
  avatars('avatars'),
  chatImages('chat_images'),
  chatAudio('chat_audio'),
  chatDocuments('chat_documents'),
  chatVideos('chat_videos');

  const StorageFolder(this.path);
  final String path;
}

class StorageService {
  StorageService._();
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  ///
  /// [file] - The file to upload
  /// [folder] - The folder to upload to
  /// [fileName] - Optional custom filename, if not provided uses original filename
  /// [userId] - User ID for organizing files by user
  ///
  /// Returns the download URL of the uploaded file
  Future<String> uploadFile({
    required File file,
    required StorageFolder folder,
    String? fileName,
    String? userId,
  }) async {
    try {
      final originalFileName = fileName ?? path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final uniqueFileName = '${timestamp}_$originalFileName';

      var uploadPath = folder.path;
      if (userId != null) {
        uploadPath = '${folder.path}/$userId/$uniqueFileName';
      } else {
        uploadPath = '${folder.path}/$uniqueFileName';
      }

      final ref = _storage.ref().child(uploadPath);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to upload file: $e');
    }
  }

  /// Upload bytes data to Firebase Storage
  ///
  /// [data] - The bytes to upload
  /// [folder] - The folder to upload to
  /// [fileName] - The filename for the uploaded data
  /// [userId] - User ID for organizing files by user
  /// [contentType] - MIME type of the data
  ///
  /// Returns the download URL of the uploaded data
  Future<String> uploadBytes({
    required Uint8List data,
    required StorageFolder folder,
    required String fileName,
    String? userId,
    String? contentType,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final uniqueFileName = '${timestamp}_$fileName';

      var uploadPath = folder.path;
      if (userId != null) {
        uploadPath = '${folder.path}/$userId/$uniqueFileName';
      } else {
        uploadPath = '${folder.path}/$uniqueFileName';
      }

      final ref = _storage.ref().child(uploadPath);

      final metadata = contentType != null
          ? SettableMetadata(contentType: contentType)
          : SettableMetadata();

      final uploadTask = ref.putData(data, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to upload bytes: $e');
    }
  }

  /// Upload an avatar image
  ///
  /// [file] - The avatar image file
  /// [userId] - The user ID
  ///
  /// Returns the download URL of the uploaded avatar
  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    return uploadFile(
      file: file,
      folder: StorageFolder.avatars,
      fileName: 'avatar${path.extension(file.path)}',
      userId: userId,
    );
  }

  /// Upload a chat image
  ///
  /// [file] - The image file
  /// [userId] - The user ID who sent the image
  /// [discussionId] - The discussion ID
  ///
  /// Returns the download URL of the uploaded image
  Future<String> uploadChatImage({
    required File file,
    required String userId,
    required String discussionId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${timestamp}_image${path.extension(file.path)}';
      final uploadPath = '$userId/$discussionId/$fileName';

      final ref = _storage.ref().child(uploadPath);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to upload chat image: $e');
    }
  }

  /// Upload a chat audio file
  ///
  /// [file] - The audio file
  /// [userId] - The user ID who sent the audio
  /// [discussionId] - The discussion ID
  ///
  /// Returns the download URL of the uploaded audio
  Future<String> uploadChatAudio({
    required File file,
    required String userId,
    required String discussionId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${timestamp}_audio${path.extension(file.path)}';
      final uploadPath = '$userId/$discussionId/$fileName';

      final ref = _storage.ref().child(uploadPath);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to upload chat audio: $e');
    }
  }

  /// Upload a chat document
  ///
  /// [file] - The document file
  /// [userId] - The user ID who sent the document
  /// [discussionId] - The discussion ID
  ///
  /// Returns the download URL of the uploaded document
  Future<String> uploadChatDocument({
    required File file,
    required String userId,
    required String discussionId,
  }) async {
    final fileName = '${discussionId}_${path.basename(file.path)}';
    return uploadFile(
      file: file,
      folder: StorageFolder.chatDocuments,
      fileName: fileName,
      userId: userId,
    );
  }

  /// Download a file from Firebase Storage
  ///
  /// [downloadUrl] - The download URL of the file
  /// [localPath] - The local path where the file should be saved
  ///
  /// Returns the local file
  Future<File> downloadFile({
    required String downloadUrl,
    required String localPath,
  }) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final localFile = File(localPath);

      await ref.writeToFile(localFile);
      return localFile;
    } catch (e) {
      throw StorageException('Failed to download file: $e');
    }
  }

  /// Get download bytes from Firebase Storage
  ///
  /// [downloadUrl] - The download URL of the file
  /// [maxSize] - Maximum size in bytes (default 10MB)
  ///
  /// Returns the file data as bytes
  Future<Uint8List> getBytes({
    required String downloadUrl,
    int maxSize = 10 * 1024 * 1024, // 10MB default
  }) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final data = await ref.getData(maxSize);

      if (data == null) {
        throw const StorageException('Failed to get file data');
      }

      return data;
    } catch (e) {
      throw StorageException('Failed to get bytes: $e');
    }
  }

  /// Delete a file from Firebase Storage
  ///
  /// [downloadUrl] - The download URL of the file to delete
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw StorageException('Failed to delete file: $e');
    }
  }

  /// Delete all files for a user
  ///
  /// [userId] - The user ID
  /// [folder] - The folder to delete from (optional, if not provided deletes from all folders)
  Future<void> deleteUserFiles({
    required String userId,
    StorageFolder? folder,
  }) async {
    try {
      if (folder != null) {
        final ref = _storage.ref().child('${folder.path}/$userId');
        final result = await ref.listAll();

        for (final fileRef in result.items) {
          await fileRef.delete();
        }
      } else {
        // Delete from all folders
        for (final folder in StorageFolder.values) {
          final ref = _storage.ref().child('${folder.path}/$userId');
          try {
            final result = await ref.listAll();
            for (final fileRef in result.items) {
              await fileRef.delete();
            }
          } on Exception catch (_) {
            // Continue if folder doesn't exist for user
            continue;
          }
        }
      }
    } catch (e) {
      throw StorageException('Failed to delete user files: $e');
    }
  }

  /// Get file metadata
  ///
  /// [downloadUrl] - The download URL of the file
  ///
  /// Returns the file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw StorageException('Failed to get file metadata: $e');
    }
  }

  /// Check if a file exists
  ///
  /// [downloadUrl] - The download URL to check
  ///
  /// Returns true if file exists, false otherwise
  Future<bool> fileExists(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.getMetadata();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}

class StorageException implements Exception {
  const StorageException(this.message);
  final String message;

  @override
  String toString() => 'StorageException: $message';
}
