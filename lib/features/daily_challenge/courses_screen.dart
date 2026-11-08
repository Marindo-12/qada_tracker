import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'course_detail_screen.dart';
import 'course_widgets.dart';
import 'data/fiqh_questions.dart';

/// Courses home: overall progress, a "continue" card, and the course list.
///
/// Progress model: a lesson = one [FiqhQuestion]. A lesson is "learned" once
/// the user has read it and tapped "فهمت". A course is complete when all of
/// its lessons are learned, and completing it unlocks the next course.
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  static const _learnedKey = 'qada.courses.learnedLessons';

  /// Set to false if you'd rather let users open any course freely.
  static const _sequentialUnlock = true;

  bool _loading = true;
  Set<int> _learned = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    if (!mounted) return;
    setState(() {
      _learned = (prefs.getStringList(_learnedKey) ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      _loading = false;
    });
  }

  Future<void> _markLearned(int questionId) async {
    if (_learned.contains(questionId)) return;
    final next = {..._learned, questionId};
    if (mounted) setState(() => _learned = next);
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setStringList(
      _learnedKey,
      next.map((e) => e.toString()).toList(),
    );
  }

  // ── Derived progress ─────────────────────────────────────────────────────
  int _total(FiqhSubject s) => questionsForSubject(s).length;

  int _done(FiqhSubject s) =>
      questionsForSubject(s).where((q) => _learned.contains(q.id)).length;

  bool _isCompleted(FiqhSubject s) {
    final t = _total(s);
    return t > 0 && _done(s) >= t;
  }

  bool _isUnlocked(int i) {
    if (!_sequentialUnlock || i == 0) return true;
    return _isCompleted(fiqhSubjects[i - 1]);
  }

  /// First unlocked course that isn't finished yet, or -1 if all are done.
  int get _currentIndex {
    for (var i = 0; i < fiqhSubjects.length; i++) {
      if (_isUnlocked(i) && !_isCompleted(fiqhSubjects[i])) return i;
    }
    return -1;
  }

  void _openCourse(int i) {
    if (!_isUnlocked(i)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'أكمل دورة «${fiqhSubjects[i - 1].name}» أولاً لفتح هذه الدورة.',
            ),
          ),
        );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(
          subject: fiqhSubjects[i],
          learned: _learned,
          onLearned: _markLearned,
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final useArabic = ref.watch(digitStyleProvider);
    final totalLessons =
        fiqhSubjects.fold<int>(0, (sum, s) => sum + _total(s));
    final doneLessons = fiqhSubjects.fold<int>(0, (sum, s) => sum + _done(s));
    final overall = totalLessons == 0 ? 0.0 : doneLessons / totalLessons;
    final current = _currentIndex;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            children: [
              _Header(
                overall: overall,
                doneLessons: doneLessons,
                totalLessons: totalLessons,
                useArabic: useArabic,
              ),
              const SizedBox(height: 22),
              if (current >= 0)
                _ContinueCard(
                  subject: fiqhSubjects[current],
                  done: _done(fiqhSubjects[current]),
                  total: _total(fiqhSubjects[current]),
                  nextLesson: _nextLessonTitle(fiqhSubjects[current]),
                  useArabic: useArabic,
                  onTap: () => _openCourse(current),
                )
              else
                const _AllDoneCard(),
              const SizedBox(height: 28),
              Text(
                'جميع الدورات',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...List.generate(fiqhSubjects.length, (i) {
                final s = fiqhSubjects[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CourseTile(
                    subject: s,
                    done: _done(s),
                    total: _total(s),
                    unlocked: _isUnlocked(i),
                    completed: _isCompleted(s),
                    lockedHint: i > 0
                        ? 'أكمل «${fiqhSubjects[i - 1].name}» لفتحها'
                        : '',
                    useArabic: useArabic,
                    onTap: () => _openCourse(i),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _nextLessonTitle(FiqhSubject s) {
    final lessons = questionsForSubject(s);
    final next = lessons.where((q) => !_learned.contains(q.id));
    return next.isEmpty ? lessons.first.question : next.first.question;
  }
}

// ─── Header with overall progress ring ───────────────────────────────────────
class _Header extends StatelessWidget {
  final double overall;
  final int doneLessons;
  final int totalLessons;
  final bool useArabic;

  const _Header({
    required this.overall,
    required this.doneLessons,
    required this.totalLessons,
    required this.useArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final percent = formatNumber((overall * 100).round(), useArabic: useArabic);

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
                '${formatNumber(doneLessons, useArabic: useArabic)} من ${formatNumber(totalLessons, useArabic: useArabic)} درساً مكتملاً',
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: overall.clamp(0.0, 1.0).toDouble(),
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
              Text(
                '$percent٪',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── "Continue learning" hero card ───────────────────────────────────────────
class _ContinueCard extends StatelessWidget {
  final FiqhSubject subject;
  final int done;
  final int total;
  final String nextLesson;
  final bool useArabic;
  final VoidCallback onTap;

  const _ContinueCard({
    required this.subject,
    required this.done,
    required this.total,
    required this.nextLesson,
    required this.useArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final started = done > 0;
    final progress = total == 0 ? 0.0 : done / total;

    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                started ? 'تابع من حيث توقفت' : 'ابدأ رحلتك',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subject.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                nextLesson,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              SlimProgress(
                value: progress,
                color: Colors.white,
                trackColor: Colors.white.withValues(alpha: 0.25),
                height: 6,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatNumber(done, useArabic: useArabic)} / ${formatNumber(total, useArabic: useArabic)} درس',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          started ? 'متابعة' : 'ابدأ',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_back_rounded, size: 18, color: primary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = AppColors.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: success, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أتممت جميع الدورات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'يمكنك مراجعة أي دورة في أي وقت.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── One course row ──────────────────────────────────────────────────────────
class _CourseTile extends StatelessWidget {
  final FiqhSubject subject;
  final int done;
  final int total;
  final bool unlocked;
  final bool completed;
  final String lockedHint;
  final bool useArabic;
  final VoidCallback onTap;

  const _CourseTile({
    required this.subject,
    required this.done,
    required this.total,
    required this.unlocked,
    required this.completed,
    required this.lockedHint,
    required this.useArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final success = AppColors.success;

    final accent = completed ? success : (unlocked ? primary : mutedFg);
    final inProgress = unlocked && !completed && done > 0;

    final subtitle = !unlocked
        ? lockedHint
        : '${formatNumber(total, useArabic: useArabic)} درساً · ${formatNumber(lessonMinutes(total), useArabic: useArabic)} دقيقة';

    return Opacity(
      opacity: unlocked ? 1 : 0.6,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border.withValues(alpha: 0.55)),
            ),
            child: Row(
              children: [
                CourseIcon(subject: subject, color: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: mutedFg),
                      ),
                      if (inProgress) ...[
                        const SizedBox(height: 10),
                        SlimProgress(
                          value: total == 0 ? 0 : done / total,
                          color: primary,
                          height: 5,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (completed)
                  Icon(Icons.check_circle_rounded, color: success)
                else if (!unlocked)
                  Icon(Icons.lock_rounded, color: mutedFg, size: 20)
                else if (inProgress)
                  Text(
                    '${formatNumber(done, useArabic: useArabic)}/${formatNumber(total, useArabic: useArabic)}',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  )
                else
                  Icon(Icons.chevron_left_rounded, color: mutedFg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}