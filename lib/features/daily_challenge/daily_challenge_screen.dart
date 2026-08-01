import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'data/fiqh_questions.dart';

/// Mutable state for a single "run" (an in-progress or just-finished
/// challenge attempt on one subject). Kept as a plain object — not a
/// widget — so we can mutate it and call setState() around the mutation,
/// same pattern the rest of the app already uses.
class _ChallengeRun {
  final FiqhSubject subject;
  final List<FiqhQuestion> questions;
  final int secondsPerQuestion;

  int index = 0;
  int score = 0;
  int correctCount = 0;
  int? selectedIndex;
  bool answered = false;
  bool isCorrect = false;
  bool finished = false;
  int remainingSeconds;

  _ChallengeRun({
    required this.subject,
    required this.questions,
    required this.secondsPerQuestion,
  }) : remainingSeconds = secondsPerQuestion;

  FiqhQuestion get currentQuestion => questions[index];
  bool get isLastQuestion => index == questions.length - 1;
}

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  static const _totalPointsKey = 'qada.challenge.totalPoints';
  static const _completedSubjectsKey = 'qada.challenge.completedSubjects';
  static const _secondsOptions = [15, 30, 60];

  Timer? _timer;
  bool _loading = true;
  int _totalPoints = 0;
  Set<String> _completedIds = {};

  /// null = browsing the subjects list. Non-null = actively playing (or
  /// just finished) a challenge run.
  _ChallengeRun? _run;

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
    if (!mounted) return;
    setState(() {
      _totalPoints = prefs.getInt(_totalPointsKey) ?? 0;
      _completedIds =
          (prefs.getStringList(_completedSubjectsKey) ?? []).toSet();
      _loading = false;
    });
  }

  bool _isUnlocked(int subjectIndex) {
    if (subjectIndex == 0) return true;
    final prevId = fiqhSubjects[subjectIndex - 1].id;
    return _completedIds.contains(prevId);
  }

  bool _isCompleted(String subjectId) => _completedIds.contains(subjectId);

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('أكمل الموضوع السابق أولاً لفتح هذا التحدي.'),
      ),
    );
  }

  // ── Settings sheet ──────────────────────────────────────────────────────
  Future<void> _openSubjectSheet(FiqhSubject subject) async {
    final available = questionsForSubject(subject).length;
    if (available == 0) return;

    final countOptions = <int>{1, if (available >= 3) 3, if (available >= 5) 5, available}
        .where((n) => n <= available)
        .toList()
      ..sort();

    int selectedCount = countOptions.last;
    int selectedSeconds = 30;

    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return _ChallengeSettingsSheet(
              subject: subject,
              countOptions: countOptions,
              selectedCount: selectedCount,
              selectedSeconds: selectedSeconds,
              secondsOptions: _secondsOptions,
              onCountChanged: (v) => setSheetState(() => selectedCount = v),
              onSecondsChanged: (v) =>
                  setSheetState(() => selectedSeconds = v),
              onStart: () => Navigator.pop(ctx, {
                'count': selectedCount,
                'seconds': selectedSeconds,
              }),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;
    _startRun(subject, result['count']!, result['seconds']!);
  }

  // ── Run lifecycle ────────────────────────────────────────────────────────
  void _startRun(FiqhSubject subject, int count, int seconds) {
    final pool = List<FiqhQuestion>.from(questionsForSubject(subject))
      ..shuffle();
    final selected = pool.take(count).toList();

    setState(() {
      _run = _ChallengeRun(
        subject: subject,
        questions: selected,
        secondsPerQuestion: seconds,
      );
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final run = _run;
      if (!mounted || run == null || run.answered || run.finished) {
        t.cancel();
        return;
      }
      if (run.remainingSeconds <= 1) {
        t.cancel();
        _submitRunAnswer(null, timedOut: true);
        return;
      }
      setState(() => run.remainingSeconds--);
    });
  }

  void _submitRunAnswer(int? index, {bool timedOut = false}) {
    final run = _run;
    if (run == null || run.answered) return;
    _timer?.cancel();

    final correct = index == run.currentQuestion.correctAnswerIndex;
    final earned = correct ? 10 + run.remainingSeconds : 0;

    setState(() {
      run.selectedIndex = index;
      run.answered = true;
      run.isCorrect = correct;
      if (correct) {
        run.score += earned;
        run.correctCount++;
      }
      if (timedOut) run.remainingSeconds = 0;
    });
  }

  void _nextQuestion() {
    final run = _run;
    if (run == null) return;

    if (run.isLastQuestion) {
      _finishRun();
      return;
    }

    setState(() {
      run.index++;
      run.selectedIndex = null;
      run.answered = false;
      run.isCorrect = false;
      run.remainingSeconds = run.secondsPerQuestion;
    });
    _startQuestionTimer();
  }

  Future<void> _finishRun() async {
    final run = _run;
    if (run == null) return;

    final prefs = await ref.read(sharedPrefsProvider.future);
    final newTotal = _totalPoints + run.score;
    final newCompleted = {..._completedIds, run.subject.id};

    await prefs.setInt(_totalPointsKey, newTotal);
    await prefs.setStringList(_completedSubjectsKey, newCompleted.toList());

    if (!mounted) return;
    setState(() {
      run.finished = true;
      _totalPoints = newTotal;
      _completedIds = newCompleted;
    });
  }

  void _closeRun() {
    _timer?.cancel();
    setState(() => _run = null);
  }

  void _confirmExitRun() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الخروج من التحدي؟'),
        content: const Text('سيُفقد تقدمك في هذا التحدي إذا خرجت الآن.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('البقاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _closeRun();
            },
            child: const Text('الخروج'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final run = _run;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: run == null ? _buildSubjectsList() : _buildRun(run),
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final useArabic = ref.watch(digitStyleProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 104),
      children: [
        // ── Centered header, no icon ─────────────────────────────────
        Center(
          child: Column(
            children: [
              Text(
                'تحديات الفقه',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'أكمل كل موضوع لتفتح الذي يليه، في الوقت الذي يناسبك.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: mutedFg, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Stat cards (bigger icons) ─────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.stars_rounded,
                label: 'النقاط الإجمالية',
                value: formatNumber(_totalPoints, useArabic: useArabic),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events_rounded,
                label: 'مواضيع مكتملة',
                value:
                    '${formatNumber(_completedIds.length, useArabic: useArabic)}/${formatNumber(fiqhSubjects.length, useArabic: useArabic)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── Subject packs ──────────────────────────────────────────────
        ...List.generate(fiqhSubjects.length, (i) {
          final subject = fiqhSubjects[i];
          final unlocked = _isUnlocked(i);
          final completed = _isCompleted(subject.id);
          final count = questionsForSubject(subject).length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SubjectTile(
              subject: subject,
              questionCount: count,
              unlocked: unlocked,
              completed: completed,
              onTap: unlocked
                  ? () => _openSubjectSheet(subject)
                  : _showLockedMessage,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRun(_ChallengeRun run) {
    final useArabic = ref.watch(digitStyleProvider);

    if (run.finished) {
      return _RunResultView(
        run: run,
        useArabic: useArabic,
        onDone: _closeRun,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 104),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _confirmExitRun,
              icon: const Icon(Icons.close_rounded),
            ),
            Expanded(
              child: Text(
                run.subject.name,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'سؤال ${formatNumber(run.index + 1, useArabic: useArabic)} من ${formatNumber(run.questions.length, useArabic: useArabic)}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.mutedFgOf(context)),
          ),
        ),
        const SizedBox(height: 14),
        _QuestionCard(
          question: run.currentQuestion,
          remainingSeconds: run.remainingSeconds,
          totalSeconds: run.secondsPerQuestion,
          answered: run.answered,
          isCorrect: run.isCorrect,
          selectedIndex: run.selectedIndex,
          useArabic: useArabic,
          onSelect: (index) => _submitRunAnswer(index),
        ),
        if (run.answered) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              child: _CenteredButtonText(
                run.isLastQuestion ? 'إنهاء التحدي' : 'السؤال التالي',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Small helper: centered text for ElevatedButton labels ───────────────────
// ElevatedButton's child isn't centered by default in every ButtonStyle
// configuration; wrapping the label text here keeps it reliably centered
// regardless of the app's global button theme.
class _CenteredButtonText extends StatelessWidget {
  final String text;

  const _CenteredButtonText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

// ─── Stat tile (bigger icon in a rounded box) ────────────────────────────────
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
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primary, size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: mutedFg, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

// ─── Subject / pack tile ──────────────────────────────────────────────────────
class _SubjectTile extends StatelessWidget {
  final FiqhSubject subject;
  final int questionCount;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.subject,
    required this.questionCount,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final theme = Theme.of(context);

    final iconColor =
        completed ? AppColors.success : (unlocked ? primary : mutedFg);

    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border.withValues(alpha: 0.55)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: subject.iconAsset != null
                    ? Image.asset(
                        subject.iconAsset!,
                        width: 28,
                        height: 28,
                        color: iconColor,
                        colorBlendMode: BlendMode.srcIn,
                      )
                    : Icon(subject.icon, color: iconColor, size: 28),
              ),
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
                    const SizedBox(height: 2),
                    Text(
                      questionCount == 1
                          ? 'سؤال واحد'
                          : '$questionCount أسئلة',
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: mutedFg),
                    ),
                  ],
                ),
              ),
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : (unlocked ? Icons.chevron_left_rounded : Icons.lock_rounded),
                color: completed ? AppColors.success : mutedFg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Challenge settings bottom sheet ──────────────────────────────────────────
class _ChallengeSettingsSheet extends StatelessWidget {
  final FiqhSubject subject;
  final List<int> countOptions;
  final int selectedCount;
  final int selectedSeconds;
  final List<int> secondsOptions;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<int> onSecondsChanged;
  final VoidCallback onStart;

  const _ChallengeSettingsSheet({
    required this.subject,
    required this.countOptions,
    required this.selectedCount,
    required this.selectedSeconds,
    required this.secondsOptions,
    required this.onCountChanged,
    required this.onSecondsChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = AppColors.surfaceOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedFg.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'إعدادات تحدي "${subject.name}"',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              Text('عدد الأسئلة',
                  style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: countOptions.map((n) {
                  final selected = n == selectedCount;
                  return ChoiceChip(
                    label: Text('$n'),
                    selected: selected,
                    onSelected: (_) => onCountChanged(n),
                    selectedColor: primary.withValues(alpha: 0.16),
                    labelStyle: TextStyle(
                      color: selected ? primary : null,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                    side: BorderSide(color: selected ? primary : border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('الوقت لكل سؤال',
                  style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: secondsOptions.map((s) {
                  final selected = s == selectedSeconds;
                  return ChoiceChip(
                    label: Text('$s ث'),
                    selected: selected,
                    onSelected: (_) => onSecondsChanged(s),
                    selectedColor: primary.withValues(alpha: 0.16),
                    labelStyle: TextStyle(
                      color: selected ? primary : null,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                    side: BorderSide(color: selected ? primary : border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onStart,
                  child: const _CenteredButtonText('ابدأ التحدي'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Result summary after finishing a run ────────────────────────────────────
class _RunResultView extends StatelessWidget {
  final _ChallengeRun run;
  final bool useArabic;
  final VoidCallback onDone;

  const _RunResultView({
    required this.run,
    required this.useArabic,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final total = run.questions.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events_rounded, color: primary, size: 46),
            ),
            const SizedBox(height: 20),
            Text(
              'أحسنت! أكملت تحدي "${run.subject.name}"',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              '${formatNumber(run.correctCount, useArabic: useArabic)} من ${formatNumber(total, useArabic: useArabic)} إجابات صحيحة',
              style: theme.textTheme.bodyLarge?.copyWith(color: mutedFg),
            ),
            const SizedBox(height: 6),
            Text(
              '+${formatNumber(run.score, useArabic: useArabic)} نقطة',
              style: theme.textTheme.titleLarge?.copyWith(
                color: primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onDone,
                child: const _CenteredButtonText('العودة إلى المواضيع'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Question card (used inside an active run) ───────────────────────────────
class _QuestionCard extends StatelessWidget {
  final FiqhQuestion question;
  final int remainingSeconds;
  final int totalSeconds;
  final bool answered;
  final bool isCorrect;
  final int? selectedIndex;
  final bool useArabic;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    required this.question,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.answered,
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
            _ResultBox(correct: isCorrect, explanation: question.explanation),
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

  const _ResultBox({
    required this.correct,
    required this.explanation,
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
        ],
      ),
    );
  }
}