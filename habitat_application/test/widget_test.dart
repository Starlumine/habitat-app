// test/bill_split_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your actual screen - adjust the path as needed
// import 'package:habitat_application/screens/bill_split_screen.dart';

// If you're using the model, import it too
// import 'package:habitat_application/models/bill_split_model.dart';

void main() {
  group('Bill Split Screen Tests', () {
    testWidgets('Screen displays input form initially', (WidgetTester tester) async {
      // TODO: Uncomment when you've added the screen to your project
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: BillSplitScreen(),
      //   ),
      // );
      //
      // // Verify input fields are present
      // expect(find.text('What\'s this for?'), findsOneWidget);
      // expect(find.text('Total Amount'), findsOneWidget);
      // expect(find.text('Who\'s sharing?'), findsOneWidget);
    });

    testWidgets('Can add participants', (WidgetTester tester) async {
      // TODO: Uncomment when you've added the screen to your project
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: BillSplitScreen(),
      //   ),
      // );
      //
      // // Find and tap the add button
      // await tester.tap(find.text('Add'));
      // await tester.pump();
      //
      // // Verify a new participant field was added
      // expect(find.text('Person 3'), findsOneWidget);
    });

    testWidgets('Calculates split correctly', (WidgetTester tester) async {
      // TODO: Uncomment when you've added the screen to your project
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: BillSplitScreen(),
      //   ),
      // );
      //
      // // Enter description
      // await tester.enterText(
      //   find.widgetWithText(TextFormField, 'What\'s this for?'),
      //   'Dinner',
      // );
      //
      // // Enter amount
      // await tester.enterText(
      //   find.widgetWithText(TextFormField, 'Total Amount'),
      //   '100',
      // );
      //
      // // Enter participant names
      // final participantFields = find.byType(TextFormField);
      // await tester.enterText(participantFields.at(2), 'Alice');
      // await tester.enterText(participantFields.at(3), 'Bob');
      //
      // // Tap calculate button
      // await tester.tap(find.text('Calculate Split'));
      // await tester.pumpAndSettle();
      //
      // // Verify the result (100 / 2 = 50)
      // expect(find.text('\$50.00'), findsOneWidget);
    });

    testWidgets('Validates empty fields', (WidgetTester tester) async {
      // TODO: Uncomment when you've added the screen to your project
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: BillSplitScreen(),
      //   ),
      // );
      //
      // // Try to calculate without filling fields
      // await tester.tap(find.text('Calculate Split'));
      // await tester.pump();
      //
      // // Verify validation messages appear
      // expect(find.text('Enter a description'), findsOneWidget);
      // expect(find.text('Enter an amount'), findsOneWidget);
    });
  });

  group('Bill Split Model Tests', () {
    test('BillSplit calculates amount per person correctly', () {
      // TODO: Uncomment when you've added the model to your project
      // final bill = BillSplit(
      //   id: '1',
      //   description: 'Test Bill',
      //   totalAmount: 100.0,
      //   participants: [
      //     Person(id: '1', name: 'Alice'),
      //     Person(id: '2', name: 'Bob'),
      //     Person(id: '3', name: 'Charlie'),
      //     Person(id: '4', name: 'Diana'),
      //   ],
      // );
      //
      // expect(bill.amountPerPerson, 25.0);
    });

    test('BillSplit converts to and from JSON correctly', () {
      // TODO: Uncomment when you've added the model to your project
      // final bill = BillSplit(
      //   id: '1',
      //   description: 'Test Bill',
      //   totalAmount: 100.0,
      //   participants: [
      //     Person(id: '1', name: 'Alice'),
      //     Person(id: '2', name: 'Bob'),
      //   ],
      // );
      //
      // final json = bill.toJson();
      // final reconstructed = BillSplit.fromJson(json);
      //
      // expect(reconstructed.id, bill.id);
      // expect(reconstructed.description, bill.description);
      // expect(reconstructed.totalAmount, bill.totalAmount);
      // expect(reconstructed.participants.length, bill.participants.length);
    });

    test('Person converts to and from JSON correctly', () {
      // TODO: Uncomment when you've added the model to your project
      // final person = Person(id: '1', name: 'Alice');
      //
      // final json = person.toJson();
      // final reconstructed = Person.fromJson(json);
      //
      // expect(reconstructed.id, person.id);
      // expect(reconstructed.name, person.name);
    });
  });
}