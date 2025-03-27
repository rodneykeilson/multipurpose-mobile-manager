import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:multipurpose_mobile_manager/main.dart';
import 'package:multipurpose_mobile_manager/provider/theme_provider.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([FirebaseApp])
void main() {
  setUpAll(() async {
    // Ensure widgets binding is initialized
    TestWidgetsFlutterBinding.ensureInitialized();

    // Use Firebase testing mode
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fakeApiKey',
        appId: 'fakeAppId',
        messagingSenderId: 'fakeMessagingSenderId',
        projectId: 'fakeProjectId',
      ),
    );
  });

  testWidgets('App starts and displays home page', (WidgetTester tester) async {
    // Create a mock FirebaseApp instance
    final mockFirebaseApp = MockFirebaseApp();

    // Build the app and trigger a frame
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MyApp(
          initialRoute: '/',
          savedLanguageCode: 'en',
        ),
      ),
    );

    // Verify that the home page is displayed
    expect(find.text('Multipurpose Mobile Manager'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}