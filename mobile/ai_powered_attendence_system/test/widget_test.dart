import 'package:flutter_test/flutter_test.dart';

import 'package:ai_powered_attendence_system/app/app.dart';

void main() {
  testWidgets('Splash shows Attendify branding', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendifyApp());

    expect(find.text('Attendify'), findsOneWidget);
    expect(find.text('Smart Attendance, Made Simple'), findsOneWidget);
  });
}
