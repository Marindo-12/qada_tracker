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

// ─── Islamic content data ────────────────────────────────────────────────────
class _IslamicContent {
  static const String bulughHelp =
      '"النِّيَّةُ تُقَوِّمُ الْعَمَلَ" — لا يُشترط الدقة المتناهية، التقدير الصادق مقبول ومعتبر.';

  static const String commitmentHelp =
      '"إِنَّ اللَّهَ يُحِبُّ أَنْ يُرَى أَثَرُ نِعْمَتِهِ عَلَى عَبْدِهِ" — حتى لو كان تقريباً، فالتوبة تجبّ ما قبلها.';

  static const String estimateHelp =
      '"وَهُوَ الَّذِي يَقْبَلُ التَّوْبَةَ عَنْ عِبَادِهِ" — التقدير لا يحتاج إلى يقين رياضي، النيّة الصادقة تكفي.';

  static const String generalEncouragement =
      '"إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ" — كل صلاة تقضيها هي خطوة نحو السكينة.';

  static const String startEncouragement =
      'قال النبي ﷺ: "أحبُّ الأعمالِ إلى اللهِ أدومُها وإن قلَّ" — ابدأ ولو بصلاة واحدة يومياً.';

  static const String approximateOk =
      'التقريب في العبادات مقبول عند العجز عن التحديد، والمقصود إبراء الذمة بنية خالصة.';
}

// ─── Approximate time options ────────────────────────────────────────────────
class _ApproxOption {
  final String label;
  final String sublabel;
  final int Function(DateTime base) toDays;

  const _ApproxOption({
    required this.label,
    required this.sublabel,
    required this.toDays,
  });
}

final _commitmentApproxOptions = [
  _ApproxOption(
    label: 'منذ سنة تقريباً',
    sublabel: 'حوالي ١٢ شهراً',
    toDays: (base) => base.difference(DateTime(base.year - 1, base.month, base.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ سنتين تقريباً',
    sublabel: 'حوالي ٢ سنوات',
    toDays: (base) => base.difference(DateTime(base.year - 2, base.month, base.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ ٥ سنوات تقريباً',
    sublabel: 'حوالي ٥ سنوات',
    toDays: (base) => base.difference(DateTime(base.year - 5, base.month, base.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ ١٠ سنوات تقريباً',
    sublabel: 'حوالي عقد كامل',
    toDays: (base) => base.difference(DateTime(base.year - 10, base.month, base.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ مطلع شبابي',
    sublabel: 'سنوات طويلة',
    toDays: (base) => base.difference(DateTime(base.year - 15, base.month, base.day)).inDays,
  ),
];

// ─── Main Setup Screen ────────────────────────────────────────────────────────
class SetupScreen extends ConsumerStatefulWidget {
  final PlanTableData? initialPlan;
  const SetupScreen({super.key, this.initialPlan});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _step = 0;
  static const int _totalSteps = 6;

  DateTime? _birthDate;
  DateTime? _bulughDate;
  bool _bulughApprox = false;
  DateTime? _commitmentDate;
  bool _commitmentApprox = false;
  int _missedDays = 1;
  int _dailyTarget = 1;
  DateTime _startDate = DateTime.now();
  String _notes = '';
  int _years = 0, _months = 0, _days = 0;
  bool _granularMode = true;
  bool _reviewConfirmed = false;
  bool _saving = false;

  int get _granularTotal => (_years * 365) + (_months * 30) + _days;

  @override
  void initState() {
    super.initState();
    final plan = widget.initialPlan;
    if (plan == null) return;
    _step = 1;
    _birthDate = isoToDate(plan.birthDate);
    _bulughDate = isoToDate(plan.bulughDate);
    _commitmentDate = isoToDate(plan.commitmentDate);
    _missedDays = plan.missedDays;
    _dailyTarget = plan.dailyTarget;
    _startDate = isoToDate(plan.startDate);
    _notes = plan.notes ?? '';
    _granularMode = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final useArabic = ref.watch(digitStyleProvider);
    final primary = AppColors.primaryOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('إعداد الخطة', style: theme.textTheme.titleLarge),
        automaticallyImplyLeading: widget.initialPlan != null,
        leading: widget.initialPlan != null
            ? IconButton(
                tooltip: 'رجوع',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
                      style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
                    ),
                    Text(
                      _stepTitle(_step),
                      style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _totalSteps,
                    minHeight: 6,
                    backgroundColor: AppColors.progressTrackOf(context),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ],
            ),
          ),

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

          _SetupNavigationBar(
            step: _step,
            isLastStep: _step == _totalSteps - 1,
            canContinue: _canProceed(),
            canSubmit: _reviewConfirmed && !_saving,
            saving: _saving,
            onPrevious: () => setState(() => _step--),
            onNext: _nextStep,
            onSubmit: _submit,
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
          bulughApprox: _bulughApprox,
          onBirthChanged: (d) => setState(() => _birthDate = d),
          onBulughChanged: (d) => setState(() => _bulughDate = d),
          onBulughApproxChanged: (v) => setState(() => _bulughApprox = v),
        );
      case 2:
        return _StepCommitment(
          bulughDate: _bulughDate,
          commitmentDate: _commitmentDate,
          commitmentApprox: _commitmentApprox,
          onChanged: (d) => setState(() => _commitmentDate = d),
          onApproxChanged: (v) => setState(() => _commitmentApprox = v),
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
          bulughApprox: _bulughApprox,
          commitmentDate: _commitmentDate,
          commitmentApprox: _commitmentApprox,
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

// ─── Nav Bar (unchanged) ──────────────────────────────────────────────────────
class _SetupNavigationBar extends StatelessWidget {
  final int step;
  final bool isLastStep, canContinue, canSubmit, saving;
  final VoidCallback onPrevious, onNext, onSubmit;

  const _SetupNavigationBar({
    required this.step,
    required this.isLastStep,
    required this.canContinue,
    required this.canSubmit,
    required this.saving,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (step > 0) ...[
              SizedBox(
                width: 52,
                height: 52,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(52, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.arrow_back, size: 22),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 56,
                child: isLastStep
                    ? ElevatedButton(
                        onPressed: canSubmit ? onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.25),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('اعتماد الخطة',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                      )
                    : ElevatedButton(
                        onPressed: canContinue ? onNext : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.25),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('التالي',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 0: Intro ────────────────────────────────────────────────────────────
class _StepIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.menu_book_rounded, size: 52, color: primary),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 32),
        Text('بسم الله نبدأ رحلة التدارك.',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          'سنقوم بجمع بعض التواريخ لنحسب تقديراً للأيام التي فاتتك فيها الصلاة، ثم نضع خطة يسيرة لقضائها بإذن الله.',
          style:
              theme.textTheme.bodyLarge?.copyWith(color: mutedFg, height: 1.8),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _IslamicBanner(
          icon: Icons.volunteer_activism_rounded,
          text: _IslamicContent.startEncouragement,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        _ReassuranceBanner(
          text:
              'لا تقلق إن لم تتذكر التواريخ بالضبط — في كل خطوة ستجد خيار التقريب. المهم النيّة الصادقة.',
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}

// ─── Step 1: Dates (with approx support) ─────────────────────────────────────
class _StepDates extends StatelessWidget {
  final DateTime? birthDate;
  final DateTime? bulughDate;
  final bool bulughApprox;
  final ValueChanged<DateTime?> onBirthChanged;
  final ValueChanged<DateTime?> onBulughChanged;
  final ValueChanged<bool> onBulughApproxChanged;

  const _StepDates({
    required this.birthDate,
    required this.bulughDate,
    required this.bulughApprox,
    required this.onBirthChanged,
    required this.onBulughChanged,
    required this.onBulughApproxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateField(
          label: 'تاريخ الميلاد',
          value: birthDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onChanged: onBirthChanged,
        ),
        const SizedBox(height: 24),

        // Bulugh section with help
        _SectionHeader(
          title: 'تاريخ البلوغ (بداية التكليف)',
          helpText: 'لا تعرف تاريخ البلوغ بالضبط؟',
          onHelpTap: () => onBulughApproxChanged(!bulughApprox),
          isHelpActive: bulughApprox,
        ),
        const SizedBox(height: 8),

        if (!bulughApprox) ...[
          _DateField(
            label: '',
            hint: 'غالباً ما يكون بين سن ١٣ و ١٥ عاماً',
            value: bulughDate,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            onChanged: onBulughChanged,
          ),
          if (birthDate != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _SuggestionChip(
                  label: 'تقدير: ١٣ سنة',
                  onTap: () => onBulughChanged(DateTime(
                      birthDate!.year + 13, birthDate!.month, birthDate!.day)),
                ),
                _SuggestionChip(
                  label: 'تقدير: ١٤ سنة',
                  onTap: () => onBulughChanged(DateTime(
                      birthDate!.year + 14, birthDate!.month, birthDate!.day)),
                ),
                _SuggestionChip(
                  label: 'تقدير: ١٥ سنة',
                  onTap: () => onBulughChanged(DateTime(
                      birthDate!.year + 15, birthDate!.month, birthDate!.day)),
                ),
              ],
            ),
          ],
        ] else ...[
          _IslamicBanner(
            icon: Icons.auto_awesome_rounded,
            text: _IslamicContent.bulughHelp,
          ).animate().fadeIn(),
          const SizedBox(height: 12),
          if (birthDate != null)
            _BulughApproxSelector(
              birthDate: birthDate!,
              selected: bulughDate,
              onSelected: onBulughChanged,
            )
          else
            _ReassuranceBanner(
              text: 'أدخل تاريخ الميلاد أولاً لنقترح عليك خيارات مناسبة.',
            ),
        ],
      ],
    );
  }
}

class _BulughApproxSelector extends StatelessWidget {
  final DateTime birthDate;
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  const _BulughApproxSelector({
    required this.birthDate,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    final options = [
      (label: 'حوالي ١٢ سنة', age: 12, note: 'تقدير أدنى'),
      (label: 'حوالي ١٣ سنة', age: 13, note: 'شائع'),
      (label: 'حوالي ١٤ سنة', age: 14, note: 'الأكثر شيوعاً ✓'),
      (label: 'حوالي ١٥ سنة', age: 15, note: 'متأخر نسبياً'),
      (label: 'حوالي ١٦ سنة', age: 16, note: 'إن تأخر البلوغ'),
    ];

    return Column(
      children: options.map((opt) {
        final date =
            DateTime(birthDate.year + opt.age, birthDate.month, birthDate.day);
        final isSelected = selected?.year == date.year &&
            selected?.month == date.month &&
            selected?.day == date.day;
        return GestureDetector(
          onTap: () => onSelected(date),
          child: AnimatedContainer(
            duration: 200.ms,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.08)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? primary.withValues(alpha: 0.5)
                    : AppColors.borderOf(context),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? primary : null)),
                      Text(opt.note,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: mutedFg)),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: primary, size: 20)
                else
                  Icon(Icons.radio_button_unchecked,
                      color: mutedFg, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Step 2: Commitment (with approx support) ─────────────────────────────────
class _StepCommitment extends StatelessWidget {
  final DateTime? bulughDate;
  final DateTime? commitmentDate;
  final bool commitmentApprox;
  final ValueChanged<DateTime?> onChanged;
  final ValueChanged<bool> onApproxChanged;

  const _StepCommitment({
    required this.bulughDate,
    required this.commitmentDate,
    required this.commitmentApprox,
    required this.onChanged,
    required this.onApproxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    final diff = bulughDate != null && commitmentDate != null
        ? commitmentDate!.difference(bulughDate!).inDays
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'تاريخ الالتزام بالصلاة',
          helpText: 'لا تتذكر التاريخ بالضبط؟',
          onHelpTap: () => onApproxChanged(!commitmentApprox),
          isHelpActive: commitmentApprox,
        ),
        const SizedBox(height: 12),

        _IslamicBanner(
          icon: Icons.favorite_rounded,
          text: _IslamicContent.commitmentHelp,
        ),
        const SizedBox(height: 16),

        if (!commitmentApprox) ...[
          _DateField(
            label: '',
            hint: 'التاريخ الذي بدأت فيه بالمحافظة على الصلاة',
            value: commitmentDate,
            firstDate: bulughDate ?? DateTime(1900),
            lastDate: DateTime.now(),
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          // Quick relative options
          Text('أو اختر تقريباً:',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: AppColors.mutedFgOf(context))),
          const SizedBox(height: 8),
          _CommitmentQuickPicker(
            bulughDate: bulughDate,
            selected: commitmentDate,
            onSelected: onChanged,
          ),
        ] else ...[
          _CommitmentApproxPicker(
            bulughDate: bulughDate,
            selected: commitmentDate,
            onSelected: onChanged,
          ),
        ],

        if (diff != null && diff > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المدة بين البلوغ والالتزام: ${(diff / 365).floor()} سنوات و ${((diff % 365) / 30).floor()} أشهر',
                    style: theme.textTheme.bodySmall?.copyWith(color: primary),
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

class _CommitmentQuickPicker extends StatelessWidget {
  final DateTime? bulughDate;
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  const _CommitmentQuickPicker({
    required this.bulughDate,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final chips = [
      ('منذ ٦ أشهر', DateTime(now.year, now.month - 6, now.day)),
      ('منذ سنة', DateTime(now.year - 1, now.month, now.day)),
      ('منذ ٣ سنوات', DateTime(now.year - 3, now.month, now.day)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((c) {
        final isAfterBulugh =
            bulughDate == null || c.$2.isAfter(bulughDate!);
        if (!isAfterBulugh) return const SizedBox.shrink();
        return _SuggestionChip(label: c.$1, onTap: () => onSelected(c.$2));
      }).toList(),
    );
  }
}

class _CommitmentApproxPicker extends StatelessWidget {
  final DateTime? bulughDate;
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  const _CommitmentApproxPicker({
    required this.bulughDate,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final now = DateTime.now();

    return Column(
      children: _commitmentApproxOptions.map((opt) {
        final date = DateTime(now.year - _labelToYears(opt.label),
            now.month, now.day);
        // Don't show option if it predates bulugh
        if (bulughDate != null && date.isBefore(bulughDate!)) {
          return const SizedBox.shrink();
        }
        final isSelected = selected != null &&
            (selected!.year == date.year) &&
            (selected!.month == date.month);
        return GestureDetector(
          onTap: () => onSelected(date),
          child: AnimatedContainer(
            duration: 200.ms,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.08)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? primary.withValues(alpha: 0.5)
                    : AppColors.borderOf(context),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? primary : null)),
                      Text(opt.sublabel,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: mutedFg)),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: primary, size: 20)
                else
                  Icon(Icons.radio_button_unchecked, color: mutedFg, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  int _labelToYears(String label) {
    if (label.contains('سنة تقريباً')) return 1;
    if (label.contains('سنتين')) return 2;
    if (label.contains('٥')) return 5;
    if (label.contains('١٠')) return 10;
    if (label.contains('شبابي')) return 15;
    return 1;
  }
}

// ─── Step 3: Estimate (with auto-calc + "I don't know" mode) ──────────────────
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

  // Auto-calculate from dates if available
  int? get _autoCalcDays {
    if (bulughDate == null || commitmentDate == null) return null;
    final diff = commitmentDate!.difference(bulughDate!).inDays;
    return diff > 0 ? diff : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final activeSurface = AppColors.surfaceOf(context);
    final autoCalc = _autoCalcDays;

    return Column(
      children: [
        _IslamicBanner(
          icon: Icons.menu_book_rounded,
          text: _IslamicContent.estimateHelp,
        ),
        const SizedBox(height: 16),

        Text(
          'قدّر بصدق الفترة التي فاتتك فيها الصلاة فعلياً.',
          style:
              theme.textTheme.bodyMedium?.copyWith(color: mutedFg, height: 1.7),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Auto-calc suggestion banner
        if (autoCalc != null) ...[
          _AutoCalcBanner(
            autoCalcDays: autoCalc,
            useArabic: useArabic,
            onAccept: () {
              final y = autoCalc ~/ 365;
              final remaining = autoCalc % 365;
              final m = remaining ~/ 30;
              final d = remaining % 30;
              onModeChanged(true);
              onYearsChanged(y);
              onMonthsChanged(m);
              onDaysChanged(d);
            },
          ),
          const SizedBox(height: 16),
        ],

        // Mode toggle
        Container(
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.5),
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
                      color:
                          granularMode ? activeSurface : Colors.transparent,
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
                            color: granularMode ? primary : mutedFg)),
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
                      color:
                          !granularMode ? activeSurface : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('عدد الأيام مباشرة',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: !granularMode ? primary : mutedFg)),
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
        const SizedBox(height: 16),

        _ReassuranceBanner(text: _IslamicContent.approximateOk),
      ],
    );
  }
}

class _AutoCalcBanner extends StatelessWidget {
  final int autoCalcDays;
  final bool useArabic;
  final VoidCallback onAccept;

  const _AutoCalcBanner({
    required this.autoCalcDays,
    required this.useArabic,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.12),
            primary.withValues(alpha: 0.06)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_fix_high, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حساب تلقائي من التواريخ',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: primary, fontWeight: FontWeight.w700)),
                Text(
                  'بناءً على ما أدخلته: ${formatNumber(autoCalcDays, useArabic: useArabic)} يوم (${formatNumber(autoCalcDays * 5, useArabic: useArabic)} صلاة)',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: primary.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAccept,
            style: TextButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('تطبيق', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
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
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);

    final presets = [
      {
        'value': 1,
        'label': 'خفيف',
        'hint': 'يوم قضاء يومياً (٥ صلوات)',
        'icon': Icons.spa_rounded
      },
      {
        'value': 2,
        'label': 'معتدل',
        'hint': 'يومان يومياً (١٠ صلوات)',
        'icon': Icons.directions_walk_rounded
      },
      {
        'value': 3,
        'label': 'نشط',
        'hint': 'ثلاثة أيام يومياً (١٥ صلاة)',
        'icon': Icons.directions_run_rounded
      },
      {
        'value': 5,
        'label': 'مكثف',
        'hint': 'خمسة أيام يومياً (٢٥ صلاة)',
        'icon': Icons.bolt_rounded
      },
    ];

    return Column(
      children: [
        _IslamicBanner(
          icon: Icons.star_rounded,
          text: _IslamicContent.generalEncouragement,
        ),
        const SizedBox(height: 16),
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
                    ? primary.withValues(alpha: 0.08)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: active
                        ? primary.withValues(alpha: 0.4)
                        : border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: active
                          ? primary.withValues(alpha: 0.12)
                          : AppColors.mutedOf(context).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(p['icon'] as IconData,
                        size: 18, color: active ? primary : mutedFg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['label'] as String,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: active ? primary : null)),
                        Text(p['hint'] as String,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: mutedFg)),
                      ],
                    ),
                  ),
                  if (active)
                    Icon(Icons.check_circle, color: primary, size: 20),
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
              color: primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'بهذا المعدل، ستنهي القضاء خلال ${formatNumber(daysNeeded, useArabic: useArabic)} يوماً',
              style: theme.textTheme.bodySmall?.copyWith(color: primary),
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

// ─── Step 5: Review (with approx badges) ─────────────────────────────────────
class _StepReview extends StatelessWidget {
  final DateTime? birthDate, bulughDate, commitmentDate;
  final bool bulughApprox, commitmentApprox;
  final int missedDays, dailyTarget;
  final DateTime startDate;
  final bool confirmed;
  final bool useArabic;
  final ValueChanged<bool> onConfirmedChanged;

  const _StepReview({
    required this.birthDate,
    required this.bulughDate,
    required this.bulughApprox,
    required this.commitmentDate,
    required this.commitmentApprox,
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
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);
    final daysNeeded =
        dailyTarget > 0 ? (missedDays / dailyTarget).ceil() : 0;

    return Column(
      children: [
        Text('راجع البيانات أدناه قبل الاعتماد.',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),

        // Review card
        Card(
          child: Column(
            children: [
              _ReviewRow(
                label: 'تاريخ الميلاد',
                value: birthDate != null
                    ? formatArabicDate(dateToIso(birthDate!))
                    : '-',
                isApprox: false,
              ),
              const Divider(height: 1),
              _ReviewRow(
                label: 'تاريخ البلوغ',
                value: bulughDate != null
                    ? formatArabicDate(dateToIso(bulughDate!))
                    : '-',
                isApprox: bulughApprox,
              ),
              const Divider(height: 1),
              _ReviewRow(
                label: 'تاريخ الالتزام',
                value: commitmentDate != null
                    ? formatArabicDate(dateToIso(commitmentDate!))
                    : '-',
                isApprox: commitmentApprox,
              ),
              const Divider(height: 1),
              _ReviewRow(
                label: 'الأيام الفائتة',
                value:
                    '${formatNumber(missedDays, useArabic: useArabic)} يوماً',
                isApprox: false,
              ),
              const Divider(height: 1),
              _ReviewRow(
                label: 'إجمالي الصلوات',
                value:
                    '${formatNumber(missedDays * 5, useArabic: useArabic)} صلاة',
                isApprox: false,
                highlight: true,
              ),
              const Divider(height: 1),
              _ReviewRow(
                label: 'الهدف اليومي',
                value:
                    '${formatNumber(dailyTarget, useArabic: useArabic)} يوم (${formatNumber(dailyTarget * 5, useArabic: useArabic)} صلاة)',
                isApprox: false,
              ),
              const Divider(height: 1),
              _ReviewRow(
                label: 'تاريخ البدء',
                value: formatArabicDate(dateToIso(startDate)),
                isApprox: false,
              ),
              if (daysNeeded > 0) ...[
                const Divider(height: 1),
                _ReviewRow(
                  label: 'مدة الإنجاز التقديرية',
                  value:
                      '${formatNumber(daysNeeded, useArabic: useArabic)} يوماً',
                  isApprox: false,
                ),
              ],
            ],
          ),
        ),

        // Approx note if applicable
        if (bulughApprox || commitmentApprox) ...[
          const SizedBox(height: 12),
          _ReassuranceBanner(
            text:
                'البيانات المحددة بعلامة "تقريبي" هي تقديرات مقبولة شرعاً عند عدم المعرفة بالضبط.',
          ),
        ],

        const SizedBox(height: 16),

        // Confirmation checkbox
        GestureDetector(
          onTap: () => onConfirmedChanged(!confirmed),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: confirmed
                  ? primary.withValues(alpha: 0.07)
                  : muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: confirmed
                    ? primary.withValues(alpha: 0.4)
                    : border,
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
                    color: confirmed ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: confirmed ? primary : mutedFg),
                  ),
                  child: confirmed
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'راجعت البيانات أعلاه وأؤكد أنها صحيحة بقدر ما أعلم، وأرغب باعتماد الخطة وحفظها.',
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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isApprox;
  final bool highlight;

  const _ReviewRow({
    required this.label,
    required this.value,
    required this.isApprox,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isApprox) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('تقريبي',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
              ],
              Text(value,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: highlight ? primary : null)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared UI Components ────────────────────────────────────────────────────

/// Section header with an optional "help / approx" toggle chip
class _SectionHeader extends StatelessWidget {
  final String title;
  final String helpText;
  final VoidCallback onHelpTap;
  final bool isHelpActive;

  const _SectionHeader({
    required this.title,
    required this.helpText,
    required this.onHelpTap,
    required this.isHelpActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: onHelpTap,
          child: AnimatedContainer(
            duration: 200.ms,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isHelpActive
                  ? primary.withValues(alpha: 0.12)
                  : AppColors.mutedOf(context).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHelpActive
                    ? primary.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHelpActive ? Icons.help : Icons.help_outline,
                  size: 13,
                  color: isHelpActive ? primary : mutedFg,
                ),
                const SizedBox(width: 4),
                Text(
                  helpText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isHelpActive ? primary : mutedFg,
                    fontWeight:
                        isHelpActive ? FontWeight.w700 : FontWeight.w500,
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

/// Green/teal Islamic quote banner
class _IslamicBanner extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IslamicBanner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.08),
            primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: primary.withValues(alpha: 0.9),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft amber/neutral reassurance banner
class _ReassuranceBanner extends StatelessWidget {
  final String text;

  const _ReassuranceBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 18,
              color: Colors.amber.shade700.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade900.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small suggestion chip
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(20),
          color: primary.withValues(alpha: 0.06),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: primary),
        ),
      ),
    );
  }
}

// ─── Shared form widgets (unchanged) ─────────────────────────────────────────
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

  DateTime _clampDate(DateTime date, DateTime min, DateTime max) {
    if (date.isBefore(min)) return min;
    if (date.isAfter(max)) return max;
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initialDate =
        _clampDate(value ?? DateTime.now(), firstDate, lastDate);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                  color: value != null
                      ? primary.withValues(alpha: 0.5)
                      : border),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18, color: value != null ? primary : mutedFg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? formatArabicDate(dateToIso(value!))
                        : (hint ?? 'اختر تاريخاً'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: value != null ? null : mutedFg),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: mutedFg),
              ],
            ),
          ),
        ),
      ],
    );
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
    final mutedFg = AppColors.mutedFgOf(context);
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
            hintStyle:
                theme.textTheme.bodySmall?.copyWith(color: mutedFg),
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
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final color = highlight ? primary : AppColors.foregroundOf(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? primary.withValues(alpha: 0.07)
            : muted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: mutedFg),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.headlineMedium?.copyWith(
                  color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}