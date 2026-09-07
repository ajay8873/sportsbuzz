import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/main.dart';

void main() {
  testWidgets('ZestApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ZestApp(),
      ),
    );

    expect(find.text('ZEST'), findsOneWidget);
  });
}
