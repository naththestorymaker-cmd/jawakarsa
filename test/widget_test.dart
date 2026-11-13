import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/main.dart';

void main() {
  testWidgets('JawaKarsaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JawaKarsaApp());
    expect(find.byType(JawaKarsaApp), findsOneWidget);
  });
}
