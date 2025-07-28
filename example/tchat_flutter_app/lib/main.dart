import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tchat_app/tchat_app.dart';

import 'discussion_list_page.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the application documents directory
  final Directory appDocDir = await getApplicationDocumentsDirectory();

  // Initialize the database with proper directory
  logger.i('Initializing database at: ${appDocDir.path}');
  await DatabaseService.initialize(directory: appDocDir.path);

  // Clear all existing data for fresh start (useful for development)
  logger.w('Clearing all database data for fresh start');
  await DatabaseService.instance.clearAllData();

  // Create and save current user
  final currentUser = User.create(name: 'You', email: 'you@example.com');

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
      title: 'TChat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DiscussionListPage(currentUser: currentUser),
    );
  }
}
