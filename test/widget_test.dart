import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qada_tracker/main.dart';

void main() {
  testWidgets('Qada app starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: QadaApp(),
      ),
    );

    expect(find.byType(QadaApp), findsOneWidget);
  });
}
