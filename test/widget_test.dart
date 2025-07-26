import 'package:flutter_test/flutter_test.dart';
import 'package:alfa_scout/main.dart';

void main() {
  testWidgets('Home screen shows Alfa Romeo Giulia', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    await tester.pumpAndSettle();

    expect(find.text('Alfa Romeo Giulia'), findsOneWidget);
  });
}