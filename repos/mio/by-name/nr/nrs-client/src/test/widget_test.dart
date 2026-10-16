import 'package:flutter_test/flutter_test.dart';
import 'package:nrs_client/screens/dial_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('DialScreen renders AU NRS by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DialScreen(
          proxyUrl: '',
          initialCountry: 'AU',
          onUpdateSettings: (proxy, country) {},
          onStartCall: (recipient, name, phone, notes, state, {password, token, country}) {},
        ),
      ),
    );

    expect(find.text('NRS Internet Relay'), findsOneWidget);
    expect(find.text('Emergency: Triple Zero (000)'), findsOneWidget);
    expect(find.text('Call 000'), findsOneWidget);
    expect(find.text('Start NRS Internet Relay Call'), findsOneWidget);
    expect(find.text('State / Territory'), findsOneWidget);
    expect(find.text('NRS Account Login'), findsOneWidget);
    expect(find.text('Log In to NRS'), findsOneWidget);
    expect(find.text('Australia (NRS)'), findsOneWidget);
    expect(find.text('New Zealand (NZ Relay)'), findsOneWidget);
    expect(find.text('NRS Helpdesk (1800 555 660)'), findsOneWidget);
  });

  testWidgets('DialScreen renders NZ Relay when initialCountry is NZ', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DialScreen(
          proxyUrl: '',
          initialCountry: 'NZ',
          onUpdateSettings: (proxy, country) {},
          onStartCall: (recipient, name, phone, notes, state, {password, token, country}) {},
        ),
      ),
    );

    expect(find.text('NZ Relay (Text Relay)'), findsOneWidget);
    expect(find.text('Emergency: Triple One (111)'), findsOneWidget);
    expect(find.text('Call 111'), findsOneWidget);
    expect(find.text('Start NZ Relay Text Call'), findsOneWidget);
    expect(find.text('Region'), findsOneWidget);
    expect(find.text('NZ Relay Account Login'), findsOneWidget);
    expect(find.text('Log In to NZ Relay'), findsOneWidget);
    expect(find.text('NZ Relay Helpdesk (0800 4 711 711)'), findsOneWidget);
    expect(find.text('Police Non-Emergency (105)'), findsOneWidget);
    expect(find.text('Healthline (0800 611 116)'), findsOneWidget);
  });

  testWidgets('DialScreen toggles from AU to NZ via SegmentedButton', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DialScreen(
          proxyUrl: '',
          initialCountry: 'AU',
          onUpdateSettings: (proxy, country) {},
          onStartCall: (recipient, name, phone, notes, state, {password, token, country}) {},
        ),
      ),
    );

    expect(find.text('Emergency: Triple Zero (000)'), findsOneWidget);

    // Tap the New Zealand button segment
    await tester.tap(find.text('New Zealand (NZ Relay)'));
    await tester.pumpAndSettle();

    expect(find.text('NZ Relay (Text Relay)'), findsOneWidget);
    expect(find.text('Emergency: Triple One (111)'), findsOneWidget);
    expect(find.text('Call 111'), findsOneWidget);
    expect(find.text('Start NZ Relay Text Call'), findsOneWidget);
    expect(find.text('Region'), findsOneWidget);
  });

  testWidgets('AU call without login shows NRS Login Required dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DialScreen(
          proxyUrl: '',
          initialCountry: 'AU',
          onUpdateSettings: (proxy, country) {},
          onStartCall: (recipient, name, phone, notes, state, {password, token, country}) {},
        ),
      ),
    );

    // Enter a number to call
    await tester.enterText(find.widgetWithText(TextField, 'Phone Number'), '0298765432');
    await tester.ensureVisible(find.text('Start NRS Internet Relay Call'));
    await tester.tap(find.text('Start NRS Internet Relay Call'));
    await tester.pumpAndSettle();

    expect(find.text('NRS Login Required'), findsOneWidget);
  });

  testWidgets('NZ call without login allows guest calling', (WidgetTester tester) async {
    String? calledRecipient;
    String? calledCountry;

    await tester.pumpWidget(
      MaterialApp(
        home: DialScreen(
          proxyUrl: '',
          initialCountry: 'NZ',
          onUpdateSettings: (proxy, country) {},
          onStartCall: (recipient, name, phone, notes, state, {password, token, country}) {
            calledRecipient = recipient;
            calledCountry = country;
          },
        ),
      ),
    );

    // Enter a number to call
    await tester.enterText(find.widgetWithText(TextField, 'Phone Number'), '0211234567');
    await tester.ensureVisible(find.text('Start NZ Relay Text Call'));
    await tester.tap(find.text('Start NZ Relay Text Call'));
    await tester.pumpAndSettle();

    // Login required dialog should NOT appear for NZ
    expect(find.text('NRS Login Required'), findsNothing);
    expect(calledRecipient, '0211234567');
    expect(calledCountry, 'NZ');
  });

  test('detectInitialCountry returns valid country code', () {
    final country = DialScreen.detectInitialCountry();
    expect(country == 'AU' || country == 'NZ', isTrue);
  });
}
