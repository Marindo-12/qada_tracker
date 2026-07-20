import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../design/design_tokens.dart';

/// Large centered hadith/quote card — used once per step, at the top.
class HadithCard extends StatelessWidget {
  final String main;
  final String sub;

  const HadithCard({super.key, required this.main, required this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: SetupDS.cardPad, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.09),
            primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(SetupDS.radiusMd),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote_rounded,
              size: 22, color: primary.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          Text(
            main,
            style: theme.textTheme.titleSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w700,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: theme.textTheme.bodySmall?.copyWith(
              color: primary.withValues(alpha: 0.75),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
