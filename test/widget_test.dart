import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Lightweight smoke test — no Hive, no Provider setup needed.
// For full integration tests use the integration_test package.
void main() {
  testWidgets('Minimal smoke test — Flutter renders a widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('PrintFlow')),
        ),
      ),
    );
    expect(find.text('PrintFlow'), findsOneWidget);
  });
}
