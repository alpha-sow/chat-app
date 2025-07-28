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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DiscussionListPage(),
    );
  }
}



