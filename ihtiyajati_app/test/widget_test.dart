// Basic widget smoke test for IhtiyajatiApp.
import 'package:flutter_test/flutter_test.dart';
import 'package:ihtiyajati_app/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IhtiyajatiApp());

    // We just verify it loads the MaterialApp.router
    expect(find.byType(IhtiyajatiApp), findsOneWidget);
  });
}
