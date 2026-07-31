import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'data/fiqh_questions.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  static const _answerSeconds = 30;
  static const _pointsKey = 'qada.challenge.points';
  static const _streakKey = 'qada.challenge.streak';
  static const _lastDateKey = 'qada.challenge.lastDate';
  static const _lastCorrectKey = 'qada.challenge.lastCorrect';
  static const _lastQuestionKey = 'qada.challenge.lastQuestionId';

  Timer? _timer;
  int _remainingSeconds = _answerSeconds;
  int? _selectedIndex;
  bool _answered = false;
  bool _isCorrect = false;
  int _points = 0;
  int _streak = 0;
  bool _loading = true;
  bool _alreadyPlayedToday = false;

  FiqhQuestion get _question => questionForDate(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    final today = todayIso();
    final playedToday = prefs.getString(_lastDateKey) == today &&
        prefs.getInt(_lastQuestionKey) == _question.id;

    if (!mounted) return;
    setState(() {
      _points = prefs.getInt(_pointsKey) ?? 0;
      _streak = prefs.getInt(_streakKey) ?? 0;
      _alreadyPlayedToday = playedToday;
      _answered = playedToday;
      _isCorrect = prefs.getBool(_lastCorrectKey) ?? false;
      _remainingSeconds = playedToday ? 0 : _answerSeconds;
      _loading = false;
    });

    if (!playedToday) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _answered) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        _submitAnswer(null, timedOut: true);
        return;
      }

      setState(() => _remainingSeconds--);
    });
  }

  Future<void> _submitAnswer(int? index, {bool timedOut = false}) async {
    if (_answered) return;

    _timer?.cancel();
    final correct = index == _question.correctAnswerIndex;
    final earnedPoints = correct ? 10 + _remainingSeconds : 0;
    final prefs = await ref.read(sharedPrefsProvider.future);
    final newStreak = correct ? _streak + 1 : 0;

    await prefs.setString(_lastDateKey, todayIso());
    await prefs.setInt(_lastQuestionKey, _question.id);
    await prefs.setBool(_lastCorrectKey, correct);
    await prefs.setInt(_pointsKey, _points + earnedPoints);
    await prefs.setInt(_streakKey, newStreak);

    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = correct;
      _alreadyPlayedToday = true;
      _points += earnedPoints;
      _streak = newStreak;
      if (timedOut) _remainingSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final useArabic = ref.watch(digitStyleProvider);
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.school_rounded, color: primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تحدي اليوم الفقهي',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'سؤال واحد كل يوم، مع نقاط حسب السرعة.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mutedFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.stars_rounded,
                      label: 'النقاط',
                      value: formatNumber(_points, useArabic: useArabic),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_fire_department_rounded,
                      label: 'السلسلة',
                      value: formatNumber(_streak, useArabic: useArabic),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _QuestionCard(
                question: _question,
                remainingSeconds: _remainingSeconds,
                totalSeconds: _answerSeconds,
                answered: _answered,
                alreadyPlayedToday: _alreadyPlayedToday,
                isCorrect: _isCorrect,
                selectedIndex: _selectedIndex,
                useArabic: useArabic,
                onSelect: (index) => _submitAnswer(index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: mutedFg, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
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

class _QuestionCard extends StatelessWidget {
  final FiqhQuestion question;
  final int remainingSeconds;
  final int totalSeconds;
  final bool answered;
  final bool alreadyPlayedToday;
  final bool isCorrect;
  final int? selectedIndex;
  final bool useArabic;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    required this.question,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.answered,
    required this.alreadyPlayedToday,
    required this.isCorrect,
    required this.selectedIndex,
    required this.useArabic,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final progress = remainingSeconds / totalSeconds;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(question.category),
                backgroundColor: primary.withValues(alpha: 0.10),
                side: BorderSide(color: primary.withValues(alpha: 0.18)),
              ),
              const Spacer(),
              Icon(Icons.timer_rounded, size: 20, color: primary),
              const SizedBox(width: 6),
              Text(
                '${formatNumber(remainingSeconds, useArabic: useArabic)}ث',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: answered ? 0.0 : progress.clamp(0.0, 1.0).toDouble(),
              backgroundColor: primary.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            question.question,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerOption(
                text: question.options[index],
                index: index,
                answered: answered,
                selected: selectedIndex == index,
                correct: question.correctAnswerIndex == index,
                onTap: () => onSelect(index),
              ),
            );
          }),
          if (answered) ...[
            const SizedBox(height: 8),
            _ResultBox(
              correct: isCorrect,
              explanation: question.explanation,
              alreadyPlayedToday: alreadyPlayedToday,
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              'اختر جوابك قبل انتهاء الوقت.',
              style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final int index;
  final bool answered;
  final bool selected;
  final bool correct;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.index,
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

    Color bg = Colors.transparent;
    Color stroke = border.withValues(alpha: 0.7);
    Color fg = Theme.of(context).colorScheme.onSurface;
    IconData? icon;

    if (answered && correct) {
      bg = AppColors.success.withValues(alpha: 0.12);
      stroke = AppColors.success;
      fg = AppColors.success;
      icon = Icons.check_circle_rounded;
    } else if (answered && selected && !correct) {
      bg = AppColors.error.withValues(alpha: 0.10);
      stroke = AppColors.error;
      fg = AppColors.error;
      icon = Icons.cancel_rounded;
    } else if (!answered) {
      bg = primary.withValues(alpha: 0.04);
    }

    return InkWell(
      onTap: answered ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: answered ? fg.withValues(alpha: 0.12) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: stroke),
              ),
              child: Text(
                const ['أ', 'ب', 'ج', 'د'][index],
                style: TextStyle(
                  color: answered ? fg : mutedFg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: answered && (correct || selected) ? fg : null,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
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

class _ResultBox extends StatelessWidget {
  final bool correct;
  final String explanation;
  final bool alreadyPlayedToday;

  const _ResultBox({
    required this.correct,
    required this.explanation,
    required this.alreadyPlayedToday,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.error;
    final title = correct ? 'إجابة صحيحة' : 'إجابة غير صحيحة';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.55,
                ),
          ),
          if (alreadyPlayedToday) ...[
            const SizedBox(height: 8),
            Text(
              'تحدي اليوم محفوظ. سؤال جديد يظهر غدا بإذن الله.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedFgOf(context),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
