import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportsbuzz/main.dart';

void main() {
  testWidgets('SportsBuzzApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SportsBuzzApp(),
      ),
    );

    expect(find.text('SportsBuzz Campus'), findsOneWidget);
  });
}
