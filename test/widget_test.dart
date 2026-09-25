import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tellal/main.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StockManagementApp());

    // Verify that our app bar and welcome text are present.
    expect(find.text('Inventory Dashboard'), findsOneWidget);
    expect(find.text('Welcome to your Stock App!'), findsOneWidget);
  });
}