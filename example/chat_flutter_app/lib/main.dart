import 'dart:io';

import 'package:chat_flutter_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chat_app_package/chat_app_package.dart';

import 'connectivity_handler.dart';
import 'discussion_list_page.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Get the application documents directory
  final Directory appDocDir = await getApplicationDocumentsDirectory();

  // Initialize the database with proper directory
  logger.i('Initializing database at: ${appDocDir.path}');
  await DatabaseService.initialize(directory: appDocDir.path);

  // Initialize Firebase Realtime Database service
  final firebaseService = FirebaseRealtimeService();

  // Initialize sync service
  SyncService.initialize(
    localDb: DatabaseService.instance,
    firebase: firebaseService,
  );

  // Start real-time synchronization
  SyncService.instance.startRealtimeSync();

  logger.i('Sync service initialized and real-time sync started');

  // Create and save current user
  final currentUser = User.create(
    id: '1991',
    name: 'You',
    email: 'you@example.com',
    avatarUrl: faker.image.loremPicsum(width: 100, height: 100),
  );
  logger.i(
    'Created current user: ${currentUser.displayName} (${currentUser.id})',
  );

  runApp(MyApp(currentUser: currentUser));
}

class MyApp extends StatelessWidget {
  final User currentUser;

  const MyApp({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ConnectionStatusWidget(
        child: DiscussionListPage(currentUser: currentUser),
      ),
      builder: (context, child) {
        // Initialize connectivity handler for the app
        ConnectivityHandler.instance.initialize(context);
        return child ?? const SizedBox();
      },
    );
  }
}
