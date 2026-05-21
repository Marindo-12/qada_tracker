// lib/features/setup/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift/drift.dart' hide Column;

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import '../../core/navigation/app_router.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _step = 0;
  static const int _totalSteps = 6;

  // Form values
  DateTime? _birthDate;
  DateTime? _bulughDate;
  DateTime? _commitmentDate;
  int _missedDays = 1;
  int _dailyTarget = 1;
  DateTime _startDate = DateTime.now();
  String _notes = '';

  // Granular estimate
  int _years = 0, _months = 0, _days = 0;
  bool _granularMode = true;

  bool _reviewConfirmed = false;
  bool _saving = false;

  int get _granularTotal => (_years * 365) + (_months * 30) + _days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useArabic = ref.watch(digitStyleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('إعداد الخطة', style: theme.textTheme.titleLarge),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الخطوة ${formatNumber(_step + 1, useArabic: useArabic)} من ${formatNumber(_totalSteps, useArabic: useArabic)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.mutedFg),
                    ),
                    Text(
                      _stepTitle(_step),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.mutedFg),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _totalSteps,
                    minHeight: 6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: 300.ms,
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStep(context, useArabic),
                ),
              ),
            ),
          ),

          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _step--),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('السابق'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _step < _totalSteps - 1
                        ? ElevatedButton(
                            onPressed: _canProceed() ? _nextStep : null,
                            child: const Text('التالي'),
                          )
                        : ElevatedButton(
                            onPressed: (_reviewConfirmed && !_saving)
                                ? _submit
                                : null,
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('اعتماد الخطة وحفظها'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    const titles = [
      'مقدمة',
      'التواريخ الأساسية',
      'تاريخ الالتزام',
      'تقدير الأيام',
      'خطة القضاء',
      'مراجعة',
    ];
    return titles[step];
  }

  bool _canProceed() {
    switch (_step) {
      case 1:
        return _birthDate != null && _bulughDate != null;
      case 2:
        return _commitmentDate != null;
      case 3:
        return _granularMode ? _granularTotal > 0 : _missedDays > 0;
      case 4:
        return _dailyTarget >= 1;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_step == 3 && _granularMode) {
      setState(() => _missedDays = _granularTotal.clamp(1, 999999));
    }
    setState(() => _step++);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final dao = ref.read(planDaoProvider);
    await dao.upsertPlan(PlanTableCompanion.insert(
      birthDate: dateToIso(_birthDate!),
      bulughDate: dateToIso(_bulughDate!),
      commitmentDate: dateToIso(_commitmentDate!),
      missedDays: _missedDays,
      dailyTarget: Value(_dailyTarget),
      startDate: dateToIso(_startDate),
      notes: Value(_notes.isEmpty ? null : _notes),
    ));
    ref.invalidate(planProvider);
    if (mounted) {
      ref.read(currentTabProvider.notifier).state = 0;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
    }
  }

  Widget _buildStep(BuildContext context, bool useArabic) {
    switch (_step) {
      case 0:
        return _StepIntro();
      case 1:
        return _StepDates(
          birthDate: _birthDate,
          bulughDate: _bulughDate,
          onBirthChanged: (d) => setState(() => _birthDate = d),
          onBulughChanged: (d) => setState(() => _bulughDate = d),
        );
      case 2:
        return _StepCommitment(
          bulughDate: _bulughDate,
          commitmentDate: _commitmentDate,
          onChanged: (d) => setState(() => _commitmentDate = d),
        );
      case 3:
        return _StepEstimate(
          bulughDate: _bulughDate,
          commitmentDate: _commitmentDate,
          granularMode: _granularMode,
          years: _years,
          months: _months,
          days: _days,
          missedDays: _missedDays,
          useArabic: useArabic,
          onModeChanged: (m) => setState(() => _granularMode = m),
          onYearsChanged: (v) => setState(() => _years = v),
          onMonthsChanged: (v) => setState(() => _months = v),
          onDaysChanged: (v) => setState(() => _days = v),
          onMissedDaysChanged: (v) => setState(() => _missedDays = v),
        );
      case 4:
        return _StepTarget(
          dailyTarget: _dailyTarget,
          missedDays: _missedDays,
          startDate: _startDate,
          notes: _notes,
          useArabic: useArabic,
          onTargetChanged: (v) => setState(() => _dailyTarget = v),
          onStartChanged: (d) => setState(() => _startDate = d),
          onNotesChanged: (v) => setState(() => _notes = v),
        );
      case 5:
        return _StepReview(
          birthDate: _birthDate,
          bulughDate: _bulughDate,
          commitmentDate: _commitmentDate,
          missedDays: _missedDays,
          dailyTarget: _dailyTarget,
          startDate: _startDate,
          confirmed: _reviewConfirmed,
          useArabic: useArabic,
          onConfirmedChanged: (v) => setState(() => _reviewConfirmed = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step 0: Intro ────────────────────────────────────────────────────────────
class _StepIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.menu_book_rounded,
              size: 52, color: AppColors.primary),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 32),
        Text('بسم الله نبدأ رحلة التدارك.',
            style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          'سنقوم بجمع بعض التواريخ لنحسب تقديراً للأيام التي فاتتك فيها الصلاة، ثم نضع خطة يسيرة لقضائها بإذن الله.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.mutedFg,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Step 1: Dates ────────────────────────────────────────────────────────────
class _StepDates extends StatelessWidget {
  final DateTime? birthDate;
  final DateTime? bulughDate;
  final ValueChanged<DateTime?> onBirthChanged;
  final ValueChanged<DateTime?> onBulughChanged;

  const _StepDates({
    required this.birthDate,
    required this.bulughDate,
    required this.onBirthChanged,
    required this.onBulughChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DateField(
          label: 'تاريخ الميلاد',
          value: birthDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onChanged: onBirthChanged,
        ),
        const SizedBox(height: 16),
        _DateField(
          label: 'تاريخ البلوغ (بداية التكليف)',
          hint: 'غالباً ما يكون بين سن ١٣ و ١٥ عاماً',
          value: bulughDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onChanged: onBulughChanged,
        ),
        if (birthDate != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              final suggested = DateTime(
                  birthDate!.year + 14, birthDate!.month, birthDate!.day);
              onBulughChanged(suggested);
            },
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: const Text('اقتراح (١٤ سنة)'),
          ),
        ],
      ],
    );
  }
}

// ─── Step 2: Commitment ───────────────────────────────────────────────────────
class _StepCommitment extends StatelessWidget {
  final DateTime? bulughDate;
  final DateTime? commitmentDate;
  final ValueChanged<DateTime?> onChanged;

  const _StepCommitment({
    required this.bulughDate,
    required this.commitmentDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = bulughDate != null && commitmentDate != null
        ? commitmentDate!.difference(bulughDate!).inDays
        : null;

    return Column(
      children: [
        _DateField(
          label: 'تاريخ الالتزام',
          hint: 'التاريخ الذي بدأت فيه بالمحافظة على الصلاة',
          value: commitmentDate,
          firstDate: bulughDate ?? DateTime(1900),
          lastDate: DateTime.now(),
          onChanged: onChanged,
        ),
        if (diff != null && diff > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المدة بين البلوغ والالتزام: ${(diff / 365).floor()} سنوات و ${((diff % 365) / 30).floor()} أشهر ($diff يوماً)',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Step 3: Estimate ─────────────────────────────────────────────────────────
class _StepEstimate extends StatelessWidget {
  final DateTime? bulughDate;
  final DateTime? commitmentDate;
  final bool granularMode;
  final int years, months, days, missedDays;
  final bool useArabic;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<int> onYearsChanged;
  final ValueChanged<int> onMonthsChanged;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<int> onMissedDaysChanged;

  const _StepEstimate({
    required this.bulughDate,
    required this.commitmentDate,
    required this.granularMode,
    required this.years,
    required this.months,
    required this.days,
    required this.missedDays,
    required this.useArabic,
    required this.onModeChanged,
    required this.onYearsChanged,
    required this.onMonthsChanged,
    required this.onDaysChanged,
    required this.onMissedDaysChanged,
  });

  int get _total => granularMode
      ? (years * 365 + months * 30 + days).clamp(0, 999999)
      : missedDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initialDate = _clampDate(value ?? DateTime.now(), firstDate, lastDate);

    return Column(
      children: [
        Text(
          'قدّر بصدق الفترة التي فاتتك فيها الصلاة فعلياً.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.mutedFg, height: 1.7),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Mode toggle
        Container(
          decoration: BoxDecoration(
            color: AppColors.muted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onModeChanged(true),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: granularMode
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: granularMode
                          ? [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4)
                            ]
                          : [],
                    ),
                    child: Text('سنوات / شهور / أيام',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: granularMode
                              ? AppColors.primary
                              : AppColors.mutedFg,
                        )),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onModeChanged(false),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !granularMode
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('عدد الأيام مباشرة',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: !granularMode
                              ? AppColors.primary
                              : AppColors.mutedFg,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (granularMode)
          Row(
            children: [
              Expanded(
                  child: _NumberInput(
                      label: 'سنوات',
                      value: years,
                      onChanged: onYearsChanged)),
              const SizedBox(width: 8),
              Expanded(
                  child: _NumberInput(
                      label: 'شهور',
                      value: months,
                      max: 11,
                      onChanged: onMonthsChanged)),
              const SizedBox(width: 8),
              Expanded(
                  child: _NumberInput(
                      label: 'أيام',
                      value: days,
                      onChanged: onDaysChanged)),
            ],
          )
        else
          _NumberInput(
            label: 'الأيام الفائتة',
            hint: 'كل يوم يعادل ٥ صلوات',
            value: missedDays,
            onChanged: onMissedDaysChanged,
          ),

        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _InfoBox(
                label: 'إجمالي الأيام',
                value: formatNumber(_total, useArabic: useArabic),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoBox(
                label: 'إجمالي الصلوات',
                value: formatNumber(_total * 5, useArabic: useArabic),
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Step 4: Target ───────────────────────────────────────────────────────────
class _StepTarget extends StatelessWidget {
  final int dailyTarget, missedDays;
  final DateTime startDate;
  final String notes;
  final bool useArabic;
  final ValueChanged<int> onTargetChanged;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<String> onNotesChanged;

  const _StepTarget({
    required this.dailyTarget,
    required this.missedDays,
    required this.startDate,
    required this.notes,
    required this.useArabic,
    required this.onTargetChanged,
    required this.onStartChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysNeeded =
        dailyTarget > 0 ? (missedDays / dailyTarget).ceil() : 0;

    final presets = [
      {'value': 1, 'label': 'خفيف', 'hint': 'يوم قضاء يومياً (٥ صلوات)'},
      {'value': 2, 'label': 'معتدل', 'hint': 'يومان يومياً (١٠ صلوات)'},
      {'value': 3, 'label': 'نشط', 'hint': 'ثلاثة أيام يومياً (١٥ صلاة)'},
      {'value': 5, 'label': 'مكثف', 'hint': 'خمسة أيام يومياً (٢٥ صلاة)'},
    ];

    return Column(
      children: [
        // Presets
        ...presets.map((p) {
          final val = p['value'] as int;
          final active = dailyTarget == val;
          return GestureDetector(
            onTap: () => onTargetChanged(val),
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['label'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: active ? AppColors.primary : null,
                            )),
                        Text(p['hint'] as String,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.mutedFg)),
                      ],
                    ),
                  ),
                  if (active)
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 20),
                ],
              ),
            ),
          );
        }),

        if (daysNeeded > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'بهذا المعدل، ستنهي القضاء خلال ${formatNumber(daysNeeded, useArabic: useArabic)} يوماً',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 16),
        _DateField(
          label: 'تاريخ البدء',
          value: startDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          onChanged: (d) => onStartChanged(d!),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'ملاحظات (اختياري)',
            hintText: 'أوقات الفراغ المناسبة للقضاء...',
          ),
          maxLines: 3,
          onChanged: onNotesChanged,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

// ─── Step 5: Review ───────────────────────────────────────────────────────────
class _StepReview extends StatelessWidget {
  final DateTime? birthDate, bulughDate, commitmentDate;
  final int missedDays, dailyTarget;
  final DateTime startDate;
  final bool confirmed;
  final bool useArabic;
  final ValueChanged<bool> onConfirmedChanged;

  const _StepReview({
    required this.birthDate,
    required this.bulughDate,
    required this.commitmentDate,
    required this.missedDays,
    required this.dailyTarget,
    required this.startDate,
    required this.confirmed,
    required this.useArabic,
    required this.onConfirmedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysNeeded =
        dailyTarget > 0 ? (missedDays / dailyTarget).ceil() : 0;

    final rows = [
      ['تاريخ الميلاد', birthDate != null ? formatArabicDate(dateToIso(birthDate!)) : '-'],
      ['تاريخ البلوغ', bulughDate != null ? formatArabicDate(dateToIso(bulughDate!)) : '-'],
      ['تاريخ الالتزام', commitmentDate != null ? formatArabicDate(dateToIso(commitmentDate!)) : '-'],
      ['الأيام الفائتة', '${formatNumber(missedDays, useArabic: useArabic)} يوماً'],
      ['إجمالي الصلوات', '${formatNumber(missedDays * 5, useArabic: useArabic)} صلاة'],
      ['الهدف اليومي', '${formatNumber(dailyTarget, useArabic: useArabic)} يوم (${formatNumber(dailyTarget * 5, useArabic: useArabic)} صلاة)'],
      ['تاريخ البدء', formatArabicDate(dateToIso(startDate))],
      if (daysNeeded > 0) ['مدة الإنجاز التقديرية', '${formatNumber(daysNeeded, useArabic: useArabic)} يوماً'],
    ];

    return Column(
      children: [
        Text('راجع البيانات أدناه قبل الاعتماد.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.mutedFg),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),

        // Review rows
        Card(
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(row[0],
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.mutedFg)),
                        Text(row[1],
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Confirmation checkbox
        GestureDetector(
          onTap: () => onConfirmedChanged(!confirmed),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: confirmed
                  ? AppColors.primary.withValues(alpha: 0.07)
                  : AppColors.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: confirmed
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: 200.ms,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: confirmed ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: confirmed ? AppColors.primary : AppColors.mutedFg,
                    ),
                  ),
                  child: confirmed
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'راجعت البيانات أعلاه وأؤكد أنها صحيحة، وأرغب باعتماد الخطة وحفظها.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final String? hint;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    required this.label,
    this.hint,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              locale: const Locale('ar'),
            );
            onChanged(picked);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                  color: value != null
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18,
                    color: value != null
                        ? AppColors.primary
                        : AppColors.mutedFg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? formatArabicDate(dateToIso(value!))
                        : (hint ?? 'اختر تاريخاً'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null ? null : AppColors.mutedFg,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.mutedFg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DateTime _clampDate(DateTime date, DateTime min, DateTime max) {
    if (date.isBefore(min)) return min;
    if (date.isAfter(max)) return max;
    return date;
  }
}

class _NumberInput extends StatefulWidget {
  final String label;
  final String? hint;
  final int value;
  final int? max;
  final ValueChanged<int> onChanged;

  const _NumberInput({
    required this.label,
    this.hint,
    required this.value,
    this.max,
    required this.onChanged,
  });

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.value.toString();
    if (!_controller.selection.isValid && _controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(widget.label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.mutedFg),
          ),
          onChanged: (v) {
            final parsed = int.tryParse(v) ?? 0;
            final clamped = widget.max != null
                ? parsed.clamp(0, widget.max!)
                : parsed.clamp(0, 999999);
            widget.onChanged(clamped);
          },
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoBox({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight ? AppColors.primary : AppColors.foreground;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.07)
            : AppColors.muted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.mutedFg),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
