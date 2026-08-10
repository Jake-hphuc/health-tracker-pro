import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_pro/main.dart';

void main() {
  testWidgets('HealthTrackerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthTrackerApp());
    expect(find.byType(HealthTrackerApp), findsOneWidget);
  });
}
