import 'package:flutter_test/flutter_test.dart';

import 'package:vibe2guys_frontend/app.dart';

void main() {
  testWidgets('login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnSightApp());
    expect(find.text('LearnSight'), findsWidgets);
    expect(find.text('계정 로그인'), findsOneWidget);
    expect(find.text('로그인'), findsAtLeastNWidgets(1));
  });
}
