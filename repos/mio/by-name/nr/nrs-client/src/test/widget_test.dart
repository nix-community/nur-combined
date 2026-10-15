import 'package:flutter_test/flutter_test.dart';
import 'package:nrs_client/screens/dial_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('NRS DialScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DialScreen(
          proxyUrl: '',
          onUpdateSettings: (proxy) {},
          onStartCall: (recipient, name, phone, notes, state) {},
        ),
      ),
    );

    expect(find.text('NRS Internet Relay'), findsOneWidget);
    expect(find.text('Emergency: Triple Zero (000)'), findsOneWidget);
    expect(find.text('Start NRS Internet Relay Call'), findsOneWidget);
    expect(find.text('State / Territory'), findsOneWidget);
  });
}
