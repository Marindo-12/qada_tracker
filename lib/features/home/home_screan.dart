// lib/features/home/home_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import '../../core/navigation/app_router.dart';
import 'widgets/today_checklist.dart';
import 'widgets/progress_card.dart';
import 'widgets/prayer_progress_breakdown.dart';
import 'widgets/streak_card.dart';
import 'widgets/recent_activity.dart';
import 'widgets/previous_day_logger.dart';
import '../setup/setup_screan.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);

    return planAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (plan) {
        if (plan == null) return const _WelcomeScreen();
        return const _Dashboard();
      },
    );
  }
}

// ─── Welcome Screen ───────────────────────────────────────────────────────────
class _WelcomeScreen extends ConsumerWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme   = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_rounded, size: 56, color: primary),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text(
                'تطبيق قضاء الصلوات',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              Text(
                'رفيقك الهادئ في رحلة التوبة وقضاء ما فاتك من الصلوات.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: mutedFg, height: 1.7),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(currentTabProvider.notifier).state = 3;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const SetupScreenWrapper()),
                    );
                  },
                  child: const Text('ابدأ رحلة القضاء',
                      style: TextStyle(fontSize: 18)),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
              const SizedBox(height: 32),
              Text(
                '"وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mutedFg,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class SetupScreenWrapper extends StatelessWidget {
  const SetupScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const SetupScreen();
}

// ─── Total Count Hero ─────────────────────────────────────────────────────────
class _TotalCountHero extends ConsumerWidget {
  const _TotalCountHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider);
    final useArabic    = ref.watch(digitStyleProvider);
    final theme        = Theme.of(context);
    final primary      = AppColors.primaryOf(context);

    return summaryAsync.when(
      loading: () => _TotalCountHeroSkeleton(primary: primary),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) {
        final completed  = summary.completedPrayers;
        final total      = summary.completedPrayers + summary.remainingPrayers;
        final remaining  = summary.remainingPrayers;
        final pct        = total > 0 ? (completed / total) : 0.0;
        final pctDisplay = (pct * 100).round();

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.isDark(context) && primary == AppColors.blueDarkPrimary
                  ? AppColors.bluePrimaryDark  // Bleu foncé pour dark mode
                  : primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -32, right: -32,
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40, left: -40,
                  child: Container(
                    width: 208, height: 208,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 112, height: 112,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(112, 112),
                              painter: _DonutPainter(
                                progress: pct.toDouble(),
                                trackColor: Colors.white.withValues(alpha: 0.15),
                                progressColor: Colors.white.withValues(alpha: 0.9),
                                strokeWidth: 9,
                              ),
                            ),
                            Text(
                              '${formatNumber(pctDisplay, useArabic: useArabic)}٪',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'إجمالي الصلوات المقضية',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatNumber(completed, useArabic: useArabic),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 42,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'من أصل ${formatNumber(total, useArabic: useArabic)} صلاة — متبقٍ ${formatNumber(remaining, useArabic: useArabic)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            if (summary.estimatedFinishDate != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'الختم المتوقع: ${formatArabicDateShort(summary.estimatedFinishDate!, useArabic: useArabic)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 700.ms).slideY(begin: -0.05);
      },
    );
  }
}

class _TotalCountHeroSkeleton extends StatelessWidget {
  final Color primary;
  const _TotalCountHeroSkeleton({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final Color  trackColor;
  final Color  progressColor;
  final double strokeWidth;

  const _DonutPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, 0, 2 * math.pi, false,
        Paint()
          ..color       = trackColor
          ..style       = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false,
        Paint()
          ..color       = progressColor
          ..style       = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap   = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}

// ─── Digit menu item (popup) ──────────────────────────────────────────────────
class _DigitMenuItem extends StatelessWidget {
  final String label;
  final String sample;
  final bool   selected;

  const _DigitMenuItem({
    required this.label,
    required this.sample,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final primary    = AppColors.primaryOf(context);
    final foreground = AppColors.foregroundOf(context);
    final mutedFg    = AppColors.mutedFgOf(context);

    return Row(
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          size: 18,
          color: selected ? primary : mutedFg,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? primary : foreground,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          sample,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: mutedFg, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// ─── Color theme menu item (popup) ───────────────────────────────────────────
class _ColorThemeMenuItem extends StatelessWidget {
  final String           label;
  final List<Color>      dots;
  final bool             selected;

  const _ColorThemeMenuItem({
    required this.label,
    required this.dots,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border  = AppColors.borderOf(context);

    return Row(
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          size: 18,
          color: selected ? primary : mutedFg,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? primary : AppColors.foregroundOf(context),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: dots
              .map((c) => Container(
                    width: 14, height: 14,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: border, width: 0.5),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── App Wordmark ─────────────────────────────────────────────────────────────
class _AppWordmark extends StatelessWidget {
  const _AppWordmark();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);

    return Transform.translate(
      offset: const Offset(0, -6),
      child: Text(
        'قضاء',
        textAlign: TextAlign.right,
        style: GoogleFonts.getFont(
          'Aref Ruqaa',
          color: primary,
          fontSize: 31,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
          shadows: [
            Shadow(
              color: primary.withValues(alpha: 0.16),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard ────────────────────────────────────────────────────────────────
class _Dashboard extends ConsumerWidget {
  const _Dashboard();

  // Métadonnées des thèmes pour le popup
  static const _colorThemes = [
    (
      value: AppColorTheme.green,
      label: 'أخضر كلاسيكي',
      dots: [Color(0xFF0D6B45), Color(0xFFB8932A), Color(0xFFF5F0E8)],
    ),
    (
      value: AppColorTheme.blue,
      label: 'أزرق حديث',
      dots: [Color(0xFF378ADD), Color(0xFF185FA5), Color(0xFFF8F9FA)],
    ),
    (
      value: AppColorTheme.gold,
      label: 'ذهبي فاخر',
      dots: [Color(0xFFB8932A), Color(0xFF8B6914), Color(0xFFF5F0E8)],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme        = Theme.of(context);
    final useArabic    = ref.watch(digitStyleProvider);
    final themeMode    = ref.watch(themeModeProvider);
    final colorTheme   = ref.watch(colorThemeProvider);  // ← nouveau
    final isDarkMode   = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 20,
        title: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: _AppWordmark(),
        ),
        actions: [
          // ── Bouton dark/light ────────────────────────────────────────
          IconButton(
            tooltip: isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
            icon: Icon(
              isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: primary,
            ),
            onPressed: () => ref
                .read(themeModeProvider.notifier)
                .set(isDarkMode ? ThemeMode.light : ThemeMode.dark),
          ),

          // ── Popup couleur du thème ───────────────────────────────────
          PopupMenuButton<AppColorTheme>(
            tooltip: 'لون التطبيق',
            icon: Icon(Icons.palette_outlined, color: primary),
            onSelected: (value) =>
                ref.read(colorThemeProvider.notifier).set(value),
            itemBuilder: (context) => _colorThemes
                .map(
                  (t) => PopupMenuItem<AppColorTheme>(
                    value: t.value,
                    child: _ColorThemeMenuItem(
                      label:    t.label,
                      dots:     t.dots,
                      selected: colorTheme == t.value,
                    ),
                  ),
                )
                .toList(),
          ),

          // ── Popup chiffres ───────────────────────────────────────────
          PopupMenuButton<bool>(
            tooltip: 'شكل الأرقام',
            icon: Icon(Icons.format_list_numbered, color: primary),
            onSelected: (value) =>
                ref.read(digitStyleProvider.notifier).set(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: true,
                child: _DigitMenuItem(
                  label:    'أرقام عربية',
                  sample:   '١٢٣',
                  selected: useArabic,
                ),
              ),
              PopupMenuItem(
                value: false,
                child: _DigitMenuItem(
                  label:    'أرقام إنجليزية',
                  sample:   '123',
                  selected: !useArabic,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayLogsProvider);
          ref.invalidate(summaryProvider);
          ref.invalidate(streakProvider);
          ref.invalidate(recentActivityProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            const _TotalCountHero(),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ورد اليوم', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    formatArabicDate(todayIso(), useArabic: useArabic),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: mutedFg),
                  ),
                ],
              ),
            ),

            const TodayChecklist(),
            const SizedBox(height: 16),
            const PreviousDayLogger(),
            const SizedBox(height: 16),
            const ProgressCard(),
            const SizedBox(height: 16),
            const PrayerProgressBreakdown(),
            const SizedBox(height: 16),
            const StreakCard(),
            const SizedBox(height: 16),
            const RecentActivityWidget(),
            const SizedBox(height: 32),

            Center(
              child: Text(
                '"قليل دائم خير من كثير منقطع"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mutedFg,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
