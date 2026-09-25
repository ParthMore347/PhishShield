import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phishshield_mobile/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('PhishShield App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => ScanHistoryProvider()),
        ],
        child: const PhishShieldApp(),
      ),
    );

    // Verify that landing page has logo or explore button
    expect(find.text('Explore PhishShield'), findsNWidgets(2));
  });
}
