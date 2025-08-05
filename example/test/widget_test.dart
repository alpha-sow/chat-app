import 'package:chat_flutter_app/main.dart';
import 'package:dayder_chat/dayder_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads with current user', (WidgetTester tester) async {
    final testUser = User.create(name: 'Test User', email: 'test@example.com');

    await tester.pumpWidget(MyApp(currentUser: testUser));

    expect(find.text('chat App - Discussions'), findsOneWidget);
  });
}
