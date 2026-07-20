import 'package:flutter_test/flutter_test.dart';
import 'package:qada_tracker/core/theme/app_theme.dart';

void main() {
  test('Arabic text styles include local Arabic font fallbacks', () {
    final theme = AppTheme.light;
    final textStyle = theme.textTheme.bodyMedium!;

    expect(textStyle.fontFamilyFallback, isNotNull);
    expect(textStyle.fontFamilyFallback, contains('Amiri'));
    expect(textStyle.fontFamilyFallback, contains('ScheherazadeNew'));
  });
}
