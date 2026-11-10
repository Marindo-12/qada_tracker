import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'challenge_screen.dart';
import 'course_progress.dart';
import 'course_widgets.dart';
import 'data/course_models.dart';
import 'lesson_screen.dart';

/// Course page: collapsing cover header, what you'll learn, the lesson
/// path, and the final challenge.
class CourseDetailScreen extends ConsumerWidget {
  final Course course;
  final CourseProgress progress;

  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.progress,
  });

  void _openLesson(BuildContext context, int index) {
    if (!progress.isLessonUnlocked(course, index)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('أتمم الدرس السابق أولاً لفتح هذا الدرس.')),
        );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          course: course,
          lessonIndex: index,
          progress: progress,
        ),
      ),
    );
  }

  void _openChallenge(BuildContext context) {
    if (!progress.allLessonsDone(course)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('أتمم جميع الدروس أولاً لتفتح التحدي النهائي.'),
          ),
        );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChallengeScreen(course: course, progress: progress),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useArabic = ref.watch(digitStyleProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final theme = Theme.of(context);
          final primary = AppColors.primaryOf(context);
          final mutedFg = AppColors.mutedFgOf(context);
          final border = AppColors.borderOf(context);
          final surface = AppColors.surfaceOf(context);

          final total = course.lessons.length;
          final done = progress.doneLessons(course);
          final allDone = progress.allLessonsDone(course);
          final completed = progress.isCourseCompleted(course);
          final next = progress.nextLessonIndex(course);

          // Primary action
          String ctaLabel;
          VoidCallback ctaAction;
          if (next != null) {
            ctaLabel = done == 0
                ? 'ابدأ الدورة'
                : 'تابع · الدرس ${formatNumber(next + 1, useArabic: useArabic)}';
            ctaAction = () => _openLesson(context, next);
          } else if (!completed) {
            ctaLabel = 'ابدأ التحدي النهائي';
            ctaAction = () => _openChallenge(context);
          } else {
            ctaLabel = 'مراجعة الدروس';
            ctaAction = () => _openLesson(context, 0);
          }

          return Scaffold(
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: ctaAction,
                    child: Text(
                      ctaLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ),
            body: CustomScrollView(
              slivers: [
                // ── Collapsing cover ──────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  backgroundColor: course.accent,
                  foregroundColor: Colors.white,
                  leading: const BackButton(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 56,
                      bottom: 16,
                    ),
                    title: Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    background: CourseCoverBackground(course: course),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        course.subtitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: course.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: mutedFg, height: 1.8),
                      ),
                      const SizedBox(height: 20),

                      // ── Stats ─────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: border.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Row(
                          children: [
                            _Stat(
                              value:
                                  formatNumber(total, useArabic: useArabic),
                              label: 'دروس',
                            ),
                            const _VDivider(),
                            _Stat(
                              value: formatNumber(course.totalMinutes,
                                  useArabic: useArabic),
                              label: 'دقيقة',
                            ),
                            const _VDivider(),
                            _Stat(
                              value:
                                  '${formatNumber(done, useArabic: useArabic)}/${formatNumber(total, useArabic: useArabic)}',
                              label: 'مكتمل',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SlimProgress(
                        value: total == 0 ? 0 : done / total,
                        color: completed ? AppColors.success : primary,
                      ),

                      // ── What you'll learn ─────────────────────────────
                      if (course.outcomes.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          'ماذا ستتعلم؟',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        for (final o in course.outcomes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(Icons.check_circle_rounded,
                                      size: 20, color: course.accent),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    o,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(height: 1.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],

                      // ── Lessons ───────────────────────────────────────
                      const SizedBox(height: 22),
                      Text(
                        'الدروس',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(total, (i) {
                        final lesson = course.lessons[i];
                        final isDone = progress.isLessonDone(course, lesson);
                        final unlocked = progress.isLessonUnlocked(course, i);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LessonTile(
                            number: formatNumber(i + 1, useArabic: useArabic),
                            title: lesson.title,
                            minutes: formatNumber(lesson.minutes,
                                useArabic: useArabic),
                            done: isDone,
                            locked: !unlocked,
                            isNext: i == next,
                            accent: course.accent,
                            onTap: () => _openLesson(context, i),
                          ),
                        );
                      }),

                      // ── Final challenge ───────────────────────────────
                      const SizedBox(height: 14),
                      _ChallengeCard(
                        locked: !allDone,
                        completed: completed,
                        bestPoints: progress.bestChallengePoints(course),
                        accent: course.accent,
                        useArabic: useArabic,
                        onTap: () => _openChallenge(context),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.mutedFgOf(context)),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.borderOf(context).withValues(alpha: 0.55),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final String number;
  final String title;
  final String minutes;
  final bool done;
  final bool locked;
  final bool isNext;
  final Color accent;
  final VoidCallback onTap;

  const _LessonTile({
    required this.number,
    required this.title,
    required this.minutes,
    required this.done,
    required this.locked,
    required this.isNext,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final success = AppColors.success;
    final theme = Theme.of(context);

    final Color badgeColor =
        done ? success : (isNext ? accent : mutedFg);

    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isNext ? accent : border.withValues(alpha: 0.55),
                width: isNext ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badgeColor.withValues(alpha: 0.14),
                  ),
                  child: done
                      ? Icon(Icons.check_rounded, size: 19, color: success)
                      : (locked
                          ? Icon(Icons.lock_rounded, size: 16, color: mutedFg)
                          : Text(
                              number,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: badgeColor,
                              ),
                            )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$minutes دقائق',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: mutedFg),
                      ),
                    ],
                  ),
                ),
                if (isNext)
                  Icon(Icons.play_circle_fill_rounded, color: accent, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final bool locked;
  final bool completed;
  final int bestPoints;
  final Color accent;
  final bool useArabic;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.locked,
    required this.completed,
    required this.bestPoints,
    required this.accent,
    required this.useArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);

    final Color color = completed ? AppColors.success : accent;
    final String subtitle = locked
        ? 'أتمم جميع الدروس لفتح التحدي'
        : (completed
            ? 'أفضل نتيجة: ${formatNumber(bestPoints, useArabic: useArabic)} نقطة'
            : 'أسئلة مؤقّتة لإتمام الدورة وفتح التي تليها');

    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    locked
                        ? Icons.lock_rounded
                        : (completed
                            ? Icons.check_rounded
                            : Icons.emoji_events_rounded),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التحدي النهائي',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: mutedFg, height: 1.5),
                      ),
                    ],
                  ),
                ),
                if (!locked)
                  Icon(Icons.chevron_left_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}