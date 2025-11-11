// test/bill_split_test.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';



import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitat_application/messaging.dart'; // make sure this path matches your project structure

void main() {
  testWidgets('ChatApp builds and shows main screen', (WidgetTester tester) async {
    // Build your app and trigger a frame
    await tester.pumpWidget(const ChatApp());

    // Verify that the main screen displays expected text
    expect(find.text('Roomates'), findsOneWidget);
    expect(find.text('Besties'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);

  });
}