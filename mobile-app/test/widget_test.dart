import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phishshield_mobile/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phishshield_mobile/services/device_profile.dart';

void main() {
  test('device profile keeps a stable ID and saves nickname/avatar', () async {
    SharedPreferences.setMockInitialValues({});
    final profile = await DeviceProfileProvider.load();
    final originalDeviceId = profile.deviceId;

    await profile.update(nickname: 'Test phone', avatarId: 'radar');
    final restoredProfile = await DeviceProfileProvider.load();

    expect(restoredProfile.deviceId, originalDeviceId);
    expect(restoredProfile.nickname, 'Test phone');
    expect(restoredProfile.avatarId, 'radar');
  });

  testWidgets('PhishShield App Smoke Test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final profile = await DeviceProfileProvider.load();
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => ScanHistoryProvider()),
          ChangeNotifierProvider.value(value: profile),
        ],
        child: const PhishShieldApp(),
      ),
    );

    // Verify that landing page has logo or explore button
    expect(find.text('Explore PhishShield'), findsNWidgets(2));
  });

  testWidgets('device profile can be edited from the app drawer',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final profile = await DeviceProfileProvider.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => ScanHistoryProvider()),
          ChangeNotifierProvider.value(value: profile),
        ],
        child: const PhishShieldApp(),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Device Profile').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'CPH test phone');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Radar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save device profile'));
    await tester.pumpAndSettle();

    expect(profile.nickname, 'CPH test phone');
    expect(profile.avatarId, 'radar');
  });
}
