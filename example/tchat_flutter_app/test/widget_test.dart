// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:tchat_app/tchat_app.dart';

import 'package:tchat_flutter_app/main.dart';

void main() {
  testWidgets('App loads with current user', (WidgetTester tester) async {
    // Create a test user
    final testUser = User.create(
      name: 'Test User',
      email: 'test@example.com',
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(currentUser: testUser));

    // Verify that the app loads
    expect(find.text('TChat App - Discussions'), findsOneWidget);
  });
}
