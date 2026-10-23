import 'package:flutter_test/flutter_test.dart';
import 'package:kalakalvision/main.dart';

void main() {
  testWidgets('KalakalVision app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KalakalVisionApp());
    expect(find.text('KalakalVision'), findsOneWidget);
  });
}
