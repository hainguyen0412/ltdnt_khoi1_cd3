import 'package:flutter_test/flutter_test.dart';

import 'package:lt_dnt_khoi1_cd3/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IsolateDemoApp());

    // Verify that the title widget is rendered.
    expect(find.text('Isolate & compute()'), findsOneWidget);
  });
}
