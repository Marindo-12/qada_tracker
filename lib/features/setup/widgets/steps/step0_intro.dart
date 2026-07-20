import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/islamic_content.dart';
import '../shared/hadith_card.dart';

class StepIntro extends StatelessWidget {
  const StepIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.menu_book_rounded, size: 44, color: primary),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'بسم الله نبدأ رحلة التدارك',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'سنجمع بعض التواريخ لنحسب تقديراً للأيام الفائتة، ثم نضع خطة يسيرة للقضاء بإذن الله.',
          style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg, height: 1.7),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        const HadithCard(main: IslamicContent.startMain, sub: IslamicContent.startSub)
            .animate()
            .fadeIn(delay: 350.ms),
      ],
    );
  }
}
