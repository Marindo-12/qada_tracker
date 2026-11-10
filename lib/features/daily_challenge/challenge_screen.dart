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

enum _Phase { intro, quiz, result }

/// Timed final challenge for a course. Passing it (70%) completes the
/// course and unlocks the next one.
class ChallengeScreen extends ConsumerStatefulWidget {
  final Course course;
  final CourseProgress progress;

  const ChallengeScreen({
    super.key,
    required this.course,
    required this.progress,
  });

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  static const _questionCount = 10;
  static const _secondsPerQuestion = 30;

  _Phase _phase = _Phase.intro;
  List<FiqhQuestion> _picked = [];
  QuizResult? _result;
  bool _passed = false;
  int _attempt = 0;

  Course get _course => widget.course;

  int get _count {
    final pool = questionsForCourse(_course).length;
    return pool < _questionCount ? pool : _questionCount;
  }

  void _start() {
    final pool = List<FiqhQuestion>.from(questionsForCourse(_course))
      ..shuffle();
    setState(() {
      _picked = pool.take(_count).toList();
      _attempt++;
      _phase = _Phase.quiz;
    });
  }

  Future<void> _onFinished(QuizResult r) async {
    final passed = r.ratio >= CourseProgress.challengePassRatio;
    await widget.progress.recordChallenge(
      course: _course,
      points: r.points,
      passed: passed,
    );
    if (!mounted) return;
    setState(() {
      _result = r;
      _passed = passed;
      _phase = _Phase.result;
    });
  }

  void _confirmExit() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الخروج من التحدي؟'),
        content: const Text('ستفقد تقدمك في هذه المحاولة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('البقاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
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
            _Phase.intro => _buildIntro(),
            _Phase.quiz => QuizRunner(
                key: ValueKey('challenge-$_attempt'),
                title: 'التحدي النهائي',
                questions: _picked,
                secondsPerQuestion: _secondsPerQuestion,
                onFinished: _onFinished,
                onExit: _confirmExit,
              ),
            _Phase.result => _buildResult(),
          },
        ),
      ),
    );
  }

  Widget _buildIntro() {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final useArabic = ref.watch(digitStyleProvider);

    Widget rule(IconData icon, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
            ],
          ),
        );

    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 170,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CourseCoverBackground(course: _course),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const GlassPill(
                              text: 'التحدي النهائي',
                              icon: Icons.emoji_events_rounded,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _course.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border.withValues(alpha: 0.55)),
                ),
                child: Column(
                  children: [
                    rule(
                      Icons.quiz_rounded,
                      '${formatNumber(_count, useArabic: useArabic)} أسئلة عشوائية من أسئلة الدورة.',
                    ),
                    rule(
                      Icons.timer_rounded,
                      '${formatNumber(_secondsPerQuestion, useArabic: useArabic)} ثانية لكل سؤال.',
                    ),
                    rule(
                      Icons.flag_rounded,
                      'النجاح بـ ${formatNumber((CourseProgress.challengePassRatio * 100).round(), useArabic: useArabic)}٪ أو أكثر لإتمام الدورة.',
                    ),
                    rule(
                      Icons.bolt_rounded,
                      'كلما أجبت أسرع حصلت على نقاط أكثر.',
                    ),
                  ],
                ),
              ),
              if (widget.progress.bestChallengePoints(_course) > 0) ...[
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'أفضل نتيجة لك: ${formatNumber(widget.progress.bestChallengePoints(_course), useArabic: useArabic)} نقطة',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(color: mutedFg),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _count == 0 ? null : _start,
              child: const Text(
                'ابدأ التحدي',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final r = _result!;
    final idx = courses.indexWhere((c) => c.id == _course.id);
    final next = (idx >= 0 && idx + 1 < courses.length) ? courses[idx + 1] : null;

    if (_passed) {
      final unlockedNext = next != null && !next.comingSoon;
      return QuizResultView(
        result: r,
        passed: true,
        title: 'أتممت دورة «${_course.title}»',
        message: unlockedNext
            ? 'حصلت على ${r.points} نقطة، وتم فتح دورة «${next?.title ?? ''}».'
            : 'حصلت على ${r.points} نقطة. بارك الله في علمك!',
        primaryLabel: 'العودة إلى الدورات',
        onPrimary: () => Navigator.of(context).popUntil((route) => route.isFirst),
        secondaryLabel: 'إعادة التحدي لتحسين نتيجتك',
        onSecondary: _start,
      );
    }

    return QuizResultView(
      result: r,
      passed: false,
      title: 'حاول مرة أخرى',
      message:
          'تحتاج إلى ${(CourseProgress.challengePassRatio * 100).round()}٪ لإتمام الدورة. راجع الدروس ثم جرّب من جديد.',
      primaryLabel: 'أعد التحدي',
      onPrimary: _start,
      secondaryLabel: 'العودة إلى الدورة',
      onSecondary: () => Navigator.pop(context),
    );
  }
}