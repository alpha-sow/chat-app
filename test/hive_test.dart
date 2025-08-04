import 'dart:io';

import 'package:chat_app_package/chat_app_package.dart';
import 'package:hive/hive.dart';
import 'package:test/test.dart';

void main() {
  group('Hive Database Tests', () {
    late LocalDatabaseService db;
    late Directory tempDir;

    setUpAll(() async {
      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('hive_test');

      // Initialize the database
      await LocalDatabaseService.initialize(directory: tempDir.path);
      db = LocalDatabaseService.instance;
    });

    tearDownAll(() async {
      // Clean up
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('can save and retrieve a user', () async {
      final testUser = User.create(
        id: 'test_user_1',
        name: 'Test User',
        email: 'test@example.com',
      );

      await db.saveUser(testUser);
      final retrievedUser = await db.getUser('test_user_1');

      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.id, equals('test_user_1'));
      expect(retrievedUser.name, equals('Test User'));
      expect(retrievedUser.email, equals('test@example.com'));
    });

    test('can save and retrieve a discussion', () async {
      final testDiscussion = Discussion.initial(
        id: 'test_discussion_1',
        title: 'Test Discussion',
        participants: ['user1', 'user2'],
      );

      await db.saveDiscussion(testDiscussion);
      final retrievedDiscussion = await db.getDiscussion('test_discussion_1');

      expect(retrievedDiscussion, isNotNull);
      expect(retrievedDiscussion!.id, equals('test_discussion_1'));
      expect(retrievedDiscussion.title, equals('Test Discussion'));
      expect(retrievedDiscussion.participants, contains('user1'));
      expect(retrievedDiscussion.participants, contains('user2'));
    });

    test('can save and retrieve messages', () async {
      final testMessage = Message.create(
        senderId: 'user1',
        content: 'Hello, World!',
      );

      await db.saveMessage(testMessage, 'test_discussion_1');
      final retrievedMessage = await db.getMessage(testMessage.id);

      expect(retrievedMessage, isNotNull);
      expect(retrievedMessage!.senderId, equals('user1'));
      expect(retrievedMessage.content, equals('Hello, World!'));
    });

    test('can get messages for discussion', () async {
      final messages = await db.getMessagesForDiscussion('test_discussion_1');
      expect(messages, isNotEmpty);
      expect(messages.first.content, equals('Hello, World!'));
    });
  });
}
