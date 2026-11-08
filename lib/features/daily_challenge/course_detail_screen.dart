import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'course_widgets.dart';
import 'data/course_info.dart';
import 'data/fiqh_questions.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Course detail: summary + lesson list + main action button
// ═════════════════════════════════════════════════════════════════════════════
class CourseDetailScreen extends ConsumerStatefulWidget {
  final FiqhSubject subject;

  /// Shared set of learned question ids (owned by the courses screen).
  final Set<int> learned;

  /// Persists a newly learned lesson.
  final Future<void> Function(int questionId) onLearned;

  const CourseDetailScreen({
    super.key,
    required this.subject,
    required this.learned,
    required this.onLearned,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  late final Set<int> _learned = {...widget.learned};
  late final List<FiqhQuestion> _lessons = questionsForSubject(widget.subject);

  int get _doneCount => _lessons.where((l) => _learned.contains(l.id)).length;

  int get _nextIndex {
    final i = _lessons.indexWhere((l) => !_learned.contains(l.id));
    return i == -1 ? 0 : i;
  }

  Future<void> _learn(int id) async {
    if (mounted) setState(() => _learned.add(id));
    await widget.onLearned(id);
  }

  Future<void> _openReader(int startIndex) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseReaderScreen(
          subject: widget.subject,
          lessons: _lessons,
          startIndex: startIndex,
          learned: _learned,
          onLearned: _learn,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final useArabic = ref.watch(digitStyleProvider);

    final total = _lessons.length;
    final done = _doneCount;
    final completed = total > 0 && done >= total;
    final progress = total == 0 ? 0.0 : done / total;
    final nextIndex = _nextIndex;

    final ctaLabel = completed
        ? 'مراجعة الدورة'
        : (done == 0 ? 'ابدأ الدورة' : 'تابع الدورة');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    // ── Title block ───────────────────────────────────────
                    Row(
                      children: [
                        CourseIcon(
                          subject: widget.subject,
                          color: completed ? AppColors.success : primary,
                          boxSize: 60,
                          iconSize: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.subject.name,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      courseDescriptions[widget.subject.id] ?? '',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: mutedFg, height: 1.7),
                    ),
                    const SizedBox(height: 20),

                    // ── Stats strip ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: border.withValues(alpha: 0.55)),
                      ),
                      child: Row(
                        children: [
                          _Stat(
                            value: formatNumber(total, useArabic: useArabic),
                            label: 'درساً',
                          ),
                          const _VDivider(),
                          _Stat(
                            value: formatNumber(lessonMinutes(total),
                                useArabic: useArabic),
                            label: 'دقيقة',
                          ),
                          const _VDivider(),
                          _Stat(
                            value:
                                '${formatNumber((progress * 100).round(), useArabic: useArabic)}٪',
                            label: 'مكتمل',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SlimProgress(
                      value: progress,
                      color: completed ? AppColors.success : primary,
                      height: 6,
                    ),
                    const SizedBox(height: 28),

                    // ── Lessons ───────────────────────────────────────────
                    Text(
                      'الدروس',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_lessons.length, (i) {
                      final lesson = _lessons[i];
                      final isDone = _learned.contains(lesson.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LessonTile(
                          number: formatNumber(i + 1, useArabic: useArabic),
                          title: lesson.question,
                          done: isDone,
                          isNext: !completed && i == nextIndex,
                          onTap: () => _openReader(i),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // ── Sticky action ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: total == 0
                        ? null
                        : () => _openReader(completed ? 0 : nextIndex),
                    child: Text(
                      ctaLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
  final bool done;
  final bool isNext;
  final VoidCallback onTap;

  const _LessonTile({
    required this.number,
    required this.title,
    required this.done,
    required this.isNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final success = AppColors.success;

    return Material(
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
              color: isNext ? primary : border.withValues(alpha: 0.55),
              width: isNext ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? success.withValues(alpha: 0.14)
                      : (isNext
                          ? primary.withValues(alpha: 0.12)
                          : mutedFg.withValues(alpha: 0.10)),
                ),
                child: done
                    ? Icon(Icons.check_rounded, size: 18, color: success)
                    : Text(
                        number,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isNext ? primary : mutedFg,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              if (isNext) ...[
                const SizedBox(width: 8),
                Icon(Icons.play_circle_fill_rounded, color: primary, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Lesson reader: one lesson per screen. Try to recall → reveal → continue.
// ═════════════════════════════════════════════════════════════════════════════
class CourseReaderScreen extends ConsumerStatefulWidget {
  final FiqhSubject subject;
  final List<FiqhQuestion> lessons;
  final int startIndex;
  final Set<int> learned;
  final Future<void> Function(int questionId) onLearned;

  const CourseReaderScreen({
    super.key,
    required this.subject,
    required this.lessons,
    required this.startIndex,
    required this.learned,
    required this.onLearned,
  });

  @override
  ConsumerState<CourseReaderScreen> createState() =>
      _CourseReaderScreenState();
}

class _CourseReaderScreenState extends ConsumerState<CourseReaderScreen> {
  late int _index = widget.startIndex;
  late bool _revealed = widget.learned.contains(widget.lessons[_index].id);
  bool _finished = false;

  FiqhQuestion get _lesson => widget.lessons[_index];
  bool get _isLast => _index == widget.lessons.length - 1;

  Future<void> _next() async {
    await widget.onLearned(_lesson.id);
    if (!mounted) return;

    if (_isLast) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _revealed = widget.learned.contains(_lesson.id);
    });
  }

  void _previous() {
    if (_index == 0) return;
    setState(() {
      _index--;
      _revealed = widget.learned.contains(_lesson.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final useArabic = ref.watch(digitStyleProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: _finished
              ? _FinishedView(
                  subject: widget.subject,
                  allDone: widget.lessons.every(
                    (l) => widget.learned.contains(l.id),
                  ),
                  onBack: () => Navigator.of(context).pop(),
                )
              : _buildLesson(useArabic),
        ),
      ),
    );
  }

  Widget _buildLesson(bool useArabic) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final success = AppColors.success;

    final total = widget.lessons.length;
    final answer = _lesson.options[_lesson.correctAnswerIndex];

    return Column(
      children: [
        // ── Top bar ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Text(
                  widget.subject.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            children: [
              SlimProgress(
                value: (_index + 1) / total,
                color: primary,
                height: 5,
              ),
              const SizedBox(height: 8),
              Text(
                'الدرس ${formatNumber(_index + 1, useArabic: useArabic)} من ${formatNumber(total, useArabic: useArabic)}',
                style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
              ),
            ],
          ),
        ),

        // ── Lesson content ──────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Text(
                'المسألة',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lesson.question,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _revealed
                    ? Column(
                        key: ValueKey('answer-${_lesson.id}'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: success.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: success.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: success, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'الجواب',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                        color: success,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  answer,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: border.withValues(alpha: 0.55),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.menu_book_rounded,
                                        color: primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'الشرح',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _lesson.explanation,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(height: 1.8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        key: ValueKey('hint-${_lesson.id}'),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded,
                                color: primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'حاول أن تتذكّر الجواب أولاً، ثم اكشفه لتتأكد.',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: mutedFg, height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),

        // ── Bottom actions ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              if (_index > 0) ...[
                SizedBox(
                  width: 54,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _previous,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: _revealed
                      ? ElevatedButton(
                          onPressed: _next,
                          child: Text(
                            _isLast ? 'إنهاء الدورة' : 'فهمت، التالي',
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => setState(() => _revealed = true),
                          child: const Text(
                            'أظهر الجواب',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinishedView extends StatelessWidget {
  final FiqhSubject subject;
  final bool allDone;
  final VoidCallback onBack;

  const _FinishedView({
    required this.subject,
    required this.allDone,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = AppColors.success;
    final mutedFg = AppColors.mutedFgOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: success, size: 52),
            ),
            const SizedBox(height: 22),
            Text(
              allDone ? 'أحسنت!' : 'انتهت الدروس',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              allDone
                  ? 'أتممت دورة «${subject.name}».'
                  : 'تبقّت دروس لم تُكمِلها في دورة «${subject.name}».',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: mutedFg, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onBack,
                child: const Text(
                  'العودة إلى الدورة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}