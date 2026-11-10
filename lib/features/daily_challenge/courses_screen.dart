import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'course_detail_screen.dart';
import 'course_progress.dart';
import 'course_widgets.dart';
import 'data/course_models.dart';
import 'data/courses_data.dart';

enum _CardState { locked, comingSoon, fresh, inProgress, completed }

/// Courses home: header, a "continue" strip, and big cover-image cards.
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  CourseProgress? _progress;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    if (!mounted) return;
    setState(() => _progress = CourseProgress(prefs));
  }

  @override
  void dispose() {
    _progress?.dispose();
    super.dispose();
  }

  _CardState _stateOf(CourseProgress p, int i) {
    final c = courses[i];
    if (!p.isCourseUnlocked(i)) return _CardState.locked;
    if (c.comingSoon) return _CardState.comingSoon;
    if (p.isCourseCompleted(c)) return _CardState.completed;
    if (p.doneLessons(c) > 0) return _CardState.inProgress;
    return _CardState.fresh;
  }

  void _open(CourseProgress p, int i) {
    final state = _stateOf(p, i);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    if (state == _CardState.locked) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'أتمم التحدي النهائي لدورة «${courses[i - 1].title}» لفتح هذه الدورة.',
          ),
        ),
      );
      return;
    }
    if (state == _CardState.comingSoon) {
      messenger.showSnackBar(
        const SnackBar(content: Text('هذه الدورة قيد الإعداد وستتوفر قريباً.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(course: courses[i], progress: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final useArabic = ref.watch(digitStyleProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: p,
            builder: (context, _) {
              // First course that is open, has content, and isn't finished.
              int current = -1;
              for (var i = 0; i < courses.length; i++) {
                final s = _stateOf(p, i);
                if (s == _CardState.fresh || s == _CardState.inProgress) {
                  current = i;
                  break;
                }
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                children: [
                  _Header(progress: p, useArabic: useArabic),
                  const SizedBox(height: 20),
                  if (current >= 0) ...[
                    _ContinueStrip(
                      course: courses[current],
                      progress: p,
                      useArabic: useArabic,
                      onTap: () => _open(p, current),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ...List.generate(courses.length, (i) {
                    final c = courses[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CourseCard(
                        course: c,
                        number: i + 1,
                        state: _stateOf(p, i),
                        done: p.doneLessons(c),
                        useArabic: useArabic,
                        onTap: () => _open(p, i),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final CourseProgress progress;
  final bool useArabic;

  const _Header({required this.progress, required this.useArabic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الدورات',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatNumber(progress.completedCourses, useArabic: useArabic)} من ${formatNumber(courses.length, useArabic: useArabic)} دورات مكتملة',
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars_rounded, color: primary, size: 20),
              const SizedBox(width: 6),
              Text(
                formatNumber(progress.points, useArabic: useArabic),
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Continue strip ──────────────────────────────────────────────────────────
class _ContinueStrip extends StatelessWidget {
  final Course course;
  final CourseProgress progress;
  final bool useArabic;
  final VoidCallback onTap;

  const _ContinueStrip({
    required this.course,
    required this.progress,
    required this.useArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    final next = progress.nextLessonIndex(course);
    final started = progress.doneLessons(course) > 0;
    final subtitle = next == null
        ? 'التحدي النهائي بانتظارك'
        : course.lessons[next].title;

    return Material(
      color: primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      started ? 'تابع من حيث توقفت' : 'ابدأ رحلتك',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: mutedFg),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${course.title} · $subtitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cover-image course card ─────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  final int number;
  final _CardState state;
  final int done;
  final bool useArabic;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.number,
    required this.state,
    required this.done,
    required this.useArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = state == _CardState.locked;
    final soon = state == _CardState.comingSoon;
    final muted = locked || soon;
    final total = course.lessons.length;

    final String meta;
    if (soon) {
      meta = 'قريباً';
    } else if (locked) {
      meta = 'أتمم الدورة السابقة لفتحها';
    } else {
      meta =
          '${formatNumber(total, useArabic: useArabic)} دروس · ${formatNumber(course.totalMinutes, useArabic: useArabic)} دقيقة';
    }

    final IconData statusIcon = switch (state) {
      _CardState.locked => Icons.lock_rounded,
      _CardState.comingSoon => Icons.hourglass_top_rounded,
      _CardState.completed => Icons.check_rounded,
      _CardState.inProgress => Icons.play_arrow_rounded,
      _CardState.fresh => Icons.arrow_back_rounded,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CourseCoverBackground(course: course, muted: muted),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GlassPill(
                        text:
                            'الدورة ${formatNumber(number, useArabic: useArabic)}',
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: state == _CardState.completed
                              ? AppColors.success
                              : Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    muted ? meta : '${course.subtitle} · $meta',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  if (state == _CardState.inProgress) ...[
                    const SizedBox(height: 10),
                    SlimProgress(
                      value: total == 0 ? 0 : done / total,
                      color: Colors.white,
                      trackColor: Colors.white.withValues(alpha: 0.28),
                      height: 5,
                    ),
                  ],
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}