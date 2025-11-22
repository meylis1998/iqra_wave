import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqra_wave/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('SplashPage shows app name and loading indicator', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    // Verify that the app name is displayed
    expect(find.text('IqraWave'), findsOneWidget);
    expect(find.text('Clean Architecture + BLoC'), findsOneWidget);

    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verify that the app icon is displayed
    expect(find.byIcon(Icons.flutter_dash), findsOneWidget);
  });
}
