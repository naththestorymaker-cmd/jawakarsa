import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/features/personalization/personalization_screen.dart';
import 'package:jawakarsa/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('JawaKarsaApp splash transitions to PersonalizationScreen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const JawaKarsaApp());
    expect(find.byType(JawaKarsaApp), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.byType(PersonalizationScreen), findsOneWidget);
  });
}
