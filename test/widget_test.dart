import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qada_tracker/core/theme/app_theme.dart';
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

  test('default theme uses the Serene Path primary emerald', () {
    final theme = AppTheme.buildTheme(brightness: Brightness.light);

    expect(theme.colorScheme.primary, const Color(0xFF003527));
  });
}
