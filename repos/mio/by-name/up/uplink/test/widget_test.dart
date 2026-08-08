// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uplink/main.dart';

void main() {
  testWidgets('UI elements smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our title and buttons are present.
    expect(find.text('Uplink Pastebin'), findsOneWidget);
    expect(find.text('Upload Text'), findsOneWidget);
    expect(find.text('Upload Image'), findsOneWidget);
    expect(find.text('Upload File'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
