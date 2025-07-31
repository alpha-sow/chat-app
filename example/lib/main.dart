import 'package:alphasow_ui/alphasow_ui.dart';
import 'package:chat_app_package/chat_app_package.dart';
import 'package:chat_flutter_app/connectivity_handler.dart';
import 'package:chat_flutter_app/discussion_list_page.dart';
import 'package:chat_flutter_app/firebase_options.dart';
import 'package:chat_flutter_app/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appDocDir = await getApplicationDocumentsDirectory();

  logger.i('Initializing database at: ${appDocDir.path}');
  await DatabaseService.initialize(directory: appDocDir.path);

  final firebaseService = FirebaseRealtimeService();

  final currentUser = User.create(
    id: '1991',
    name: 'You',
    email: 'you@example.com',
    avatarUrl: faker.image.loremPicsum(width: 100, height: 100),
  );
  logger.i(
    'Created current user: ${currentUser.displayName} (${currentUser.id})',
  );

  SyncService.initialize(
    localDb: DatabaseService.instance,
    firebase: firebaseService,
    currentUserId: currentUser.id,
  );
  await SyncService.instance.saveUser(currentUser);

  SyncService.instance.startRealtimeSync();

  logger.i('Sync service initialized and real-time sync started');
  runApp(MyApp(currentUser: currentUser));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.currentUser, super.key});
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return AlphasowUiApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: ConnectionStatusWidget(
        child: DiscussionListPage(currentUser: currentUser),
      ),
    );
  }
}
