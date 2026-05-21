import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import 'setup_screan.dart';

class SetupIntroScreen extends StatefulWidget {
  const SetupIntroScreen({super.key});

  @override
  State<SetupIntroScreen> createState() => _SetupIntroScreenState();
}

class _SetupIntroScreenState extends State<SetupIntroScreen> {
  static const _appName = 'قضاء الصلوات';
  late final List<String> _letters;
  Timer? _timer;
  int _visibleLetters = 0;

  @override
  void initState() {
    super.initState();
    _letters = _appName.runes.map(String.fromCharCode).toList();
    _timer = Timer.periodic(95.ms, (timer) {
      if (!mounted) return;
      if (_visibleLetters >= _letters.length) {
        timer.cancel();
        return;
      }
      setState(() => _visibleLetters++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleName = _letters.take(_visibleLetters).join();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          children: [
            const SizedBox(height: 24),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                visibleName,
                textAlign: TextAlign.right,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                width: 92,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2),
            const SizedBox(height: 36),
            Text(
              'رفيق هادئ يساعدك على تنظيم قضاء الصلوات الفائتة بخطة يومية واضحة، ومتابعة تقدمك بدون تعقيد.',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.foreground,
                height: 1.8,
              ),
            ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.12),
            const SizedBox(height: 24),
            const _IntroPoint(
              icon: Icons.calendar_month_outlined,
              title: 'حدد الفترة',
              text: 'أدخل التواريخ الأساسية أو عدد الأيام التقريبي التي تريد قضاءها.',
            ).animate().fadeIn(delay: 1250.ms).slideY(begin: 0.16),
            const _IntroPoint(
              icon: Icons.track_changes_outlined,
              title: 'اختر روتينك',
              text: 'اختر عدد الأيام التي تناسبك يومياً، ويمكنك إضافة أكثر من صلاة في نفس اليوم.',
            ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.16),
            const _IntroPoint(
              icon: Icons.insights_outlined,
              title: 'تابع الإنجاز',
              text: 'راقب ما أنجزته، المتبقي، السلسلة اليومية، وتقويم التقدم.',
            ).animate().fadeIn(delay: 1550.ms).slideY(begin: 0.16),
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetupScreen()),
                  );
                },
                child: const Text(
                  'إنشاء خطة القضاء',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ).animate().fadeIn(delay: 1750.ms).slideY(begin: 0.2),
            const SizedBox(height: 14),
            Text(
              'يمكنك تعديل الخطة لاحقاً من الإعدادات.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedFg),
            ).animate().fadeIn(delay: 1900.ms),
          ],
        ),
      ),
    );
  }
}

class _IntroPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _IntroPoint({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedFg,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
