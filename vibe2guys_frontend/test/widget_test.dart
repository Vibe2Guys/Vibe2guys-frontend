import 'package:flutter_test/flutter_test.dart';

import 'package:vibe2guys_frontend/app.dart';

void main() {
  testWidgets('login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const Vibe2GuysApp());
    expect(find.text('Vibe2Guys LMS'), findsWidgets);
    expect(find.text('로그인'), findsOneWidget);
  });
}
