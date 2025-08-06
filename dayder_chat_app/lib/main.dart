import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:dayder_chat_app/page/page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  String dbPath;
  if (kIsWeb) {
    // Web doesn't support getApplicationDocumentsDirectory
    dbPath = '/web_db';
    logger.i('Initializing database for web at: $dbPath');
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    dbPath = appDocDir.path;
    logger.i('Initializing database at: $dbPath');
  }

  await LocalDatabaseService.initialize(directory: dbPath);

  final firebaseService = RemoteDatabaseService();

  final currentUser = User.create(
    id: '1754396919307',
    name: 'Ben',
    email: 'ben@example.com',
    avatarUrl: faker.image.loremPicsum(width: 100, height: 100),
  );
  logger.i(
    'Created current user: ${currentUser.displayName} (${currentUser.id})',
  );

  SyncService.initialize(
    localDb: LocalDatabaseService.instance(),
    firebase: firebaseService,
    currentUserId: currentUser.id,
  );
  await SyncService.instance().saveUser(currentUser);

  SyncService.instance().startRealtimeSync();

  logger.i('Sync service initialized and real-time sync started');
  runApp(MyApp(currentUser: currentUser));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.currentUser, super.key});
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return AlphasowUiApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: DiscussionList(currentUser: currentUser),
    );
  }
}
