import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'course_progress.dart';
import 'course_widgets.dart';
import 'data/course_models.dart';
import 'data/courses_data.dart';
import 'data/fiqh_questions.dart';
import 'quiz_runner.dart';

enum _Phase { reading, quiz, result }

/// One lesson: read the content -> take a short quiz -> see the result.
/// Passing the quiz (60%) marks the lesson complete and unlocks the next one.
class LessonScreen extends ConsumerStatefulWidget {
  final Course course;
  final int lessonIndex;
  final CourseProgress progress;

  const LessonScreen({
    super.key,
    required this.course,
    required this.lessonIndex,
    required this.progress,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final ScrollController _scroll = ScrollController();

  late int _index = widget.lessonIndex;
  _Phase _phase = _Phase.reading;
  QuizResult? _result;
  bool _passed = false;
  int _attempt = 0;
  double _read = 0;

  Course get _course => widget.course;
  Lesson get _lesson => _course.lessons[_index];
  bool get _hasNext => _index < _course.lessons.length - 1;

  List<FiqhQuestion> get _quiz =>
      _lesson.quizIds.map(questionById).whereType<FiqhQuestion>().toList();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      final p = max <= 0 ? 1.0 : (_scroll.offset / max).clamp(0.0, 1.0);
      if ((p - _read).abs() > 0.01) setState(() => _read = p);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    if (_quiz.isEmpty) {
      // No questions attached: reading the lesson is enough.
      await widget.progress.recordLesson(
        course: _course,
        lesson: _lesson,
        correct: 0,
        passed: true,
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() {
      _attempt++;
      _phase = _Phase.quiz;
    });
  }

  Future<void> _onQuizFinished(QuizResult r) async {
    final passed = r.ratio >= CourseProgress.lessonPassRatio;
    await widget.progress.recordLesson(
      course: _course,
      lesson: _lesson,
      correct: r.correct,
      passed: passed,
    );
    if (!mounted) return;
    setState(() {
      _result = r;
      _passed = passed;
      _phase = _Phase.result;
    });
  }

  void _backToReading() {
    setState(() {
      _phase = _Phase.reading;
      _read = 0;
    });
  }

  void _goNextLesson() {
    setState(() {
      _index++;
      _phase = _Phase.reading;
      _read = 0;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _confirmExitQuiz() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الخروج من الاختبار؟'),
        content: const Text('ستفقد إجاباتك في هذه المحاولة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('البقاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _backToReading();
            },
            child: const Text('الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: switch (_phase) {
            _Phase.reading => _buildReading(),
            _Phase.quiz => QuizRunner(
                key: ValueKey('quiz-$_index-$_attempt'),
                title: _lesson.title,
                questions: _quiz,
                onFinished: _onQuizFinished,
                onExit: _confirmExitQuiz,
              ),
            _Phase.result => _buildResult(),
          },
        ),
      ),
    );
  }

  // ── Reading ──────────────────────────────────────────────────────────────
  Widget _buildReading() {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final useArabic = ref.watch(digitStyleProvider);

    return Column(
      children: [
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
                  _course.title,
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
          child: SlimProgress(value: _read, color: primary, height: 4),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.menu_book_rounded,
                    text:
                        'الدرس ${formatNumber(_index + 1, useArabic: useArabic)} من ${formatNumber(_course.lessons.length, useArabic: useArabic)}',
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    text:
                        '${formatNumber(_lesson.minutes, useArabic: useArabic)} دقائق',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _lesson.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              for (final b in _lesson.blocks) _BlockView(block: b),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'انتهى الدرس. اختبر فهمك لتفتح الدرس التالي.',
                  style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _startQuiz,
              child: const Text(
                'اختبر فهمك',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Result ───────────────────────────────────────────────────────────────
  Widget _buildResult() {
    final r = _result!;

    if (_passed) {
      return QuizResultView(
        result: r,
        passed: true,
        title: 'أحسنت!',
        message: _hasNext
            ? 'أتممت هذا الدرس، وتم فتح الدرس التالي.'
            : 'أتممت جميع دروس الدورة. أمامك الآن التحدي النهائي.',
        primaryLabel: _hasNext ? 'الدرس التالي' : 'العودة إلى الدورة',
        onPrimary: _hasNext ? _goNextLesson : () => Navigator.pop(context),
        secondaryLabel: _hasNext ? 'العودة إلى الدورة' : 'مراجعة الدرس',
        onSecondary:
            _hasNext ? () => Navigator.pop(context) : _backToReading,
      );
    }

    return QuizResultView(
      result: r,
      passed: false,
      title: 'اقتربت!',
      message:
          'تحتاج إلى ${(CourseProgress.lessonPassRatio * 100).round()}٪ لإتمام الدرس. راجع الدرس ثم أعد المحاولة.',
      primaryLabel: 'أعد الاختبار',
      onPrimary: _startQuiz,
      secondaryLabel: 'مراجعة الدرس',
      onSecondary: _backToReading,
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Block renderer
// ═════════════════════════════════════════════════════════════════════════════
class _BlockView extends StatelessWidget {
  final LessonBlock block;

  const _BlockView({required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    switch (block.type) {
      case BlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 26, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.text,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );

      case BlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            block.text,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.95),
          ),
        );

      case BlockType.points:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border.withValues(alpha: 0.55)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (block.title.isNotEmpty) ...[
                  Text(
                    block.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                ],
                for (var i = 0; i < block.items.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == block.items.length - 1 ? 0 : 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            block.items[i],
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.75),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );

      case BlockType.evidence:
        // A coloured bar + tinted body. (Built with a Row instead of a
        // one-sided Border so it can have rounded corners.)
        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: primary),
                  Expanded(
                    child: Container(
                      color: primary.withValues(alpha: 0.07),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            block.text,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 2.0,
                            ),
                          ),
                          if (block.source != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.format_quote_rounded,
                                    size: 16, color: mutedFg),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    block.source!,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: mutedFg),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case BlockType.example:
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kGold.withValues(alpha: 0.45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: kGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      block.title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: kGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  block.text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.8),
                ),
              ],
            ),
          ),
        );

      case BlockType.note:
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kGold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_rounded, color: kGold, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    block.text,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(height: 1.75, color: mutedFg),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}