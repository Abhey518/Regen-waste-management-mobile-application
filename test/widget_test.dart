import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app1/main.dart';

void main() {
  testWidgets('Sign in page renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const WasteManagementApp());

    // Verify the sign in page elements are present
    expect(find.text('Regen'), findsOneWidget);
    expect(find.text('Waste Management'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // NIC and Password fields
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('New User? Register Now'), findsOneWidget);
  });

  testWidgets('Navigate to registration page', (WidgetTester tester) async {
    await tester.pumpWidget(const WasteManagementApp());

    // Tap the register button
    await tester.tap(find.text('New User? Register Now'));
    await tester.pumpAndSettle();

    // Verify we're on the registration page
    expect(find.text('Register'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5)); // All registration fields
    expect(find.text('Register Now'), findsOneWidget);
  });

  testWidgets('Registration form validation', (WidgetTester tester) async {
    await tester.pumpWidget(const WasteManagementApp());

    // Go to registration page
    await tester.tap(find.text('New User? Register Now'));
    await tester.pumpAndSettle();

    // Try to submit empty form
    await tester.tap(find.text('Register Now'));
    await tester.pump();

    // Should show validation errors
    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    // Add more validation checks as needed
  });
}
