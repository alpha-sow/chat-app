import 'dart:io';

import 'package:chat_app_package/src/models/models.dart';
import 'package:hive/hive.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Hive Models Tests', () {
    late Directory tempDir;

    setUpAll(() async {
      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HiveMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HiveDiscussionAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(HiveUserAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('can create and convert Message to HiveMessage', () async {
      final testMessage = Message.create(
        senderId: 'user1',
        content: 'Hello, World!',
      );

      final hiveMessage = HiveMessage.fromMessage(testMessage, 'discussion1');
      final convertedBack = hiveMessage.toMessage();

      expect(convertedBack.senderId, equals('user1'));
      expect(convertedBack.content, equals('Hello, World!'));
      expect(convertedBack.type, equals(MessageType.text));
    });

    test('can create and convert User to HiveUser', () async {
      final testUser = User.create(
        id: 'test_user_1',
        name: 'Test User',
        email: 'test@example.com',
      );

      final hiveUser = HiveUser.fromUser(testUser);
      final convertedBack = hiveUser.toUser();

      expect(convertedBack.id, equals('test_user_1'));
      expect(convertedBack.name, equals('Test User'));
      expect(convertedBack.email, equals('test@example.com'));
    });

    test('can create and convert Discussion to HiveDiscussion', () async {
      final testDiscussion = Discussion.initial(
        id: 'test_discussion_1',
        title: 'Test Discussion',
        participants: ['user1', 'user2'],
      );

      final hiveDiscussion = HiveDiscussion.fromDiscussion(testDiscussion);
      final convertedBack = hiveDiscussion.toDiscussion();

      expect(convertedBack.id, equals('test_discussion_1'));
      expect(convertedBack.title, equals('Test Discussion'));
      expect(convertedBack.participants, contains('user1'));
      expect(convertedBack.participants, contains('user2'));
    });

    test('can save and retrieve from Hive boxes', () async {
      final messagesBox = await Hive.openBox<HiveMessage>('test_messages');
      final usersBox = await Hive.openBox<HiveUser>('test_users');
      final discussionsBox = await Hive.openBox<HiveDiscussion>(
        'test_discussions',
      );

      // Test message storage
      final testMessage = Message.create(
        senderId: 'user1',
        content: 'Hello, World!',
      );
      final hiveMessage = HiveMessage.fromMessage(testMessage, 'discussion1');
      await messagesBox.put(testMessage.id, hiveMessage);

      final retrievedMessage = messagesBox.get(testMessage.id);
      expect(retrievedMessage, isNotNull);
      expect(retrievedMessage!.content, equals('Hello, World!'));

      // Test user storage
      final testUser = User.create(
        id: 'test_user_1',
        name: 'Test User',
        email: 'test@example.com',
      );
      final hiveUser = HiveUser.fromUser(testUser);
      await usersBox.put(testUser.id, hiveUser);

      final retrievedUser = usersBox.get(testUser.id);
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.name, equals('Test User'));

      // Test discussion storage
      final testDiscussion = Discussion.initial(
        id: 'test_discussion_1',
        title: 'Test Discussion',
        participants: ['user1', 'user2'],
      );
      final hiveDiscussion = HiveDiscussion.fromDiscussion(testDiscussion);
      await discussionsBox.put(testDiscussion.id, hiveDiscussion);

      final retrievedDiscussion = discussionsBox.get(testDiscussion.id);
      expect(retrievedDiscussion, isNotNull);
      expect(retrievedDiscussion!.title, equals('Test Discussion'));

      // Clean up
      await messagesBox.close();
      await usersBox.close();
      await discussionsBox.close();
    });
  });
}
