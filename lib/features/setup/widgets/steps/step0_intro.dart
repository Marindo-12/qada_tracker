import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/islamic_content.dart';
import '../../data/arabic_names.dart';
import '../shared/hadith_card.dart';

/// ─── Step: Intro ────────────────────────────────────────────────────────
///
/// Now a ConsumerWidget: reads the saved username (userNameProvider) and
/// picks the avatar icon accordingly — man-icon.png if the name is
/// recognized as male, woman-icon.png if recognized as female. If the
/// name is missing or not found in either list (arabic_names.dart),
/// falls back to man-icon.png (the original default) rather than
/// guessing.
class StepIntro extends ConsumerWidget {
  const StepIntro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    final userNameAsync = ref.watch(userNameProvider);
    final name = userNameAsync.valueOrNull;
    final isMale = name == null ? null : isMaleArabicName(name);
    // isMale == false  -> recognized female -> woman icon
    // isMale == true / null (unknown, not yet loaded, no name) -> man icon
    final avatarAsset = isMale == false
        ? 'assets/icon/woman-icon.png'
        : 'assets/icon/man-icon.png';

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 116,
          height: 116,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: primary.withValues(alpha: 0.12), width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              avatarAsset,
              key: ValueKey(avatarAsset),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Icon(Icons.person_rounded, size: 44, color: primary),
            ),
          ),
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