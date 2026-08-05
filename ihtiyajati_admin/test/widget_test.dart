// Smoke test for IhtiyajatiAdminApp
import 'package:flutter_test/flutter_test.dart';
import 'package:ihtiyajati_admin/main.dart';

void main() {
  testWidgets('Admin smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IhtiyajatiAdminApp());
    expect(find.byType(IhtiyajatiAdminApp), findsOneWidget);
  });
}
