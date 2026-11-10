import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'course_widgets.dart';
import 'data/fiqh_questions.dart';

class QuizResult {
  final int correct;
  final int total;
  final int points;

  const QuizResult({
    required this.correct,
    required this.total,
    required this.points,
  });

  double get ratio => total == 0 ? 0 : correct / total;
}

/// One question with its options shuffled for this run, so the right answer
/// isn't always in the same position.
class _RunQ {
  final FiqhQuestion q;
  final List<int> order;

  _RunQ(this.q)
      : order = (List<int>.generate(q.options.length, (i) => i)..shuffle());

  int get correct => order.indexOf(q.correctAnswerIndex);
  String optionAt(int i) => q.options[order[i]];
}

/// Plays a list of questions. Untimed when [secondsPerQuestion] is null.
/// Calls [onFinished] after the last question; [onExit] when the user taps X.
class QuizRunner extends ConsumerStatefulWidget {
  final List<FiqhQuestion> questions;
  final int? secondsPerQuestion;
  final String title;
  final ValueChanged<QuizResult> onFinished;
  final VoidCallback onExit;

  const QuizRunner({
    super.key,
    required this.questions,
    required this.title,
    required this.onFinished,
    required this.onExit,
    this.secondsPerQuestion,
  });

  @override
  ConsumerState<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends ConsumerState<QuizRunner> {
  late final List<_RunQ> _qs;
  Timer? _timer;

  int _i = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  int _points = 0;
  int _remaining = 0;

  bool get _timed => widget.secondsPerQuestion != null;
  _RunQ get _cur => _qs[_i];
  bool get _isLast => _i == _qs.length - 1;

  @override
  void initState() {
    super.initState();
    _qs = (List<FiqhQuestion>.from(widget.questions)..shuffle())
        .map((q) => _RunQ(q))
        .toList();
    if (_timed) {
      _remaining = widget.secondsPerQuestion!;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _answered) {
        t.cancel();
        return;
      }
      if (_remaining <= 1) {
        t.cancel();
        _answer(null);
        return;
      }
      setState(() => _remaining--);
    });
  }

  void _answer(int? index) {
    if (_answered) return;
    _timer?.cancel();
    final ok = index != null && index == _cur.correct;
    setState(() {
      _selected = index;
      _answered = true;
      if (ok) {
        _correct++;
        _points += 10 + (_timed ? _remaining : 0);
      }
      if (index == null) _remaining = 0;
    });
  }

  void _next() {
    if (_isLast) {
      widget.onFinished(
        QuizResult(correct: _correct, total: _qs.length, points: _points),
      );
      return;
    }
    setState(() {
      _i++;
      _selected = null;
      _answered = false;
      if (_timed) _remaining = widget.secondsPerQuestion!;
    });
    if (_timed) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final useArabic = ref.watch(digitStyleProvider);
    final q = _cur;

    return Column(
      children: [
        // ── Top bar ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onExit,
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(
                width: 64,
                child: _timed
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_rounded, size: 18, color: primary),
                          const SizedBox(width: 4),
                          Text(
                            formatNumber(_remaining, useArabic: useArabic),
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            children: [
              SlimProgress(
                value: _timed && !_answered
                    ? _remaining / widget.secondsPerQuestion!
                    : (_i + (_answered ? 1 : 0)) / _qs.length,
                color: primary,
                height: 5,
              ),
              const SizedBox(height: 8),
              Text(
                'سؤال ${formatNumber(_i + 1, useArabic: useArabic)} من ${formatNumber(_qs.length, useArabic: useArabic)}',
                style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
              ),
            ],
          ),
        ),

        // ── Question + options ────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            children: [
              Text(
                q.q.question,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              ...List.generate(q.order.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionTile(
                    letter: const ['أ', 'ب', 'ج', 'د'][i],
                    text: q.optionAt(i),
                    answered: _answered,
                    selected: _selected == i,
                    correct: q.correct == i,
                    onTap: () => _answer(i),
                  ),
                );
              }),
              if (_answered) ...[
                const SizedBox(height: 6),
                _Feedback(
                  correct: _selected != null && _selected == q.correct,
                  timedOut: _selected == null,
                  explanation: q.q.explanation,
                ),
              ],
            ],
          ),
        ),

        // ── Next ──────────────────────────────────────────────────────
        if (_answered)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _isLast ? 'عرض النتيجة' : 'السؤال التالي',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool answered;
  final bool selected;
  final bool correct;
  final VoidCallback onTap;

  const _OptionTile({
    required this.letter,
    required this.text,
    required this.answered,
    required this.selected,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = AppColors.borderOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final primary = AppColors.primaryOf(context);
    final surface = AppColors.surfaceOf(context);

    Color bg = primary.withValues(alpha: 0.04);
    Color stroke = border.withValues(alpha: 0.7);
    Color? fg;
    IconData? icon;

    if (answered && correct) {
      bg = AppColors.success.withValues(alpha: 0.12);
      stroke = AppColors.success;
      fg = AppColors.success;
      icon = Icons.check_circle_rounded;
    } else if (answered && selected) {
      bg = AppColors.error.withValues(alpha: 0.10);
      stroke = AppColors.error;
      fg = AppColors.error;
      icon = Icons.cancel_rounded;
    } else if (answered) {
      bg = Colors.transparent;
    }

    return InkWell(
      onTap: answered ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fg != null ? fg.withValues(alpha: 0.12) : surface,
                shape: BoxShape.circle,
                border: Border.all(color: stroke),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  color: fg ?? mutedFg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: fg, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  final bool correct;
  final bool timedOut;
  final String explanation;

  const _Feedback({
    required this.correct,
    required this.timedOut,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.error;
    final title = correct
        ? 'إجابة صحيحة'
        : (timedOut ? 'انتهى الوقت' : 'إجابة غير صحيحة');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.verified_rounded : Icons.info_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

/// Result screen shared by lesson quizzes and the final challenge.
class QuizResultView extends ConsumerWidget {
  final QuizResult result;
  final bool passed;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const QuizResultView({
    super.key,
    required this.result,
    required this.passed,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final useArabic = ref.watch(digitStyleProvider);
    final color = passed ? AppColors.success : AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.check_rounded : Icons.refresh_rounded,
                color: color,
                size: 52,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatNumber(result.correct, useArabic: useArabic)} من ${formatNumber(result.total, useArabic: useArabic)} إجابات صحيحة',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: mutedFg, height: 1.7),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onPrimary,
                child: Text(
                  primaryLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            if (secondaryLabel != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}