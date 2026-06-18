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
class _IC {
  static const bulughHelp =
      '"النِّيَّةُ تُقَوِّمُ الْعَمَلَ"';
  static const bulughSub =
      'لا يُشترط الدقة المتناهية، التقدير الصادق مقبول ومعتبر.';

  static const commitmentHelp =
      '"إِنَّ اللَّهَ يُحِبُّ أَنْ يُرَى أَثَرُ نِعْمَتِهِ عَلَى عَبْدِهِ"';
  static const commitmentSub =
      'حتى لو كان تقريباً، فالتوبة تجبّ ما قبلها.';

  static const estimateHelp =
      '"وَهُوَ الَّذِي يَقْبَلُ التَّوْبَةَ عَنْ عِبَادِهِ"';
  static const estimateSub =
      'التقدير لا يحتاج إلى يقين رياضي، النيّة الصادقة تكفي.';

  static const generalMain =
      '"إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ"';
  static const generalSub =
      'كل صلاة تقضيها هي خطوة نحو السكينة.';

  static const startMain =
      '"أحبُّ الأعمالِ إلى اللهِ أدومُها وإن قلَّ"';
  static const startSub = 'ابدأ ولو بصلاة واحدة يومياً. — النبي ﷺ';

  static const approxOk =
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
    toDays: (b) => b.difference(DateTime(b.year - 1, b.month, b.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ سنتين تقريباً',
    sublabel: 'حوالي ٢ سنوات',
    toDays: (b) => b.difference(DateTime(b.year - 2, b.month, b.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ ٥ سنوات تقريباً',
    sublabel: 'حوالي ٥ سنوات',
    toDays: (b) => b.difference(DateTime(b.year - 5, b.month, b.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ ١٠ سنوات تقريباً',
    sublabel: 'حوالي عقد كامل',
    toDays: (b) => b.difference(DateTime(b.year - 10, b.month, b.day)).inDays,
  ),
  _ApproxOption(
    label: 'منذ مطلع شبابي',
    sublabel: 'سنوات طويلة',
    toDays: (b) => b.difference(DateTime(b.year - 15, b.month, b.day)).inDays,
  ),
];

// ─── Design tokens ───────────────────────────────────────────────────────────
// Shared spacing, radius, and durations used throughout the setup flow
class _DS {
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double cardPad = 18;
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
}

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

  static const _stepTitles = [
    'مقدمة',
    'التواريخ الأساسية',
    'تاريخ الالتزام',
    'تقدير الأيام',
    'خطة القضاء',
    'مراجعة',
  ];

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

  Widget _buildStep(bool useArabic) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useArabic = ref.watch(digitStyleProvider);
    final primary = AppColors.primaryOf(context);
    final progress = (_step + 1) / _totalSteps;

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _StepHeader(
            step: _step,
            totalSteps: _totalSteps,
            title: _stepTitles[_step],
            progress: progress,
            useArabic: useArabic,
            primary: primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: AnimatedSwitcher(
                duration: _DS.normal,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStep(useArabic),
                ),
              ),
            ),
          ),
          _NavBar(
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
}

// ─── Step Header (progress + breadcrumb) ─────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final int step, totalSteps;
  final String title;
  final double progress;
  final bool useArabic;
  final Color primary;

  const _StepHeader({
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.progress,
    required this.useArabic,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Step dots
              Row(
                children: List.generate(totalSteps, (i) {
                  final done = i < step;
                  final active = i == step;
                  return AnimatedContainer(
                    duration: _DS.fast,
                    margin: const EdgeInsets.only(left: 4),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: done || active
                          ? primary
                          : AppColors.mutedOf(context).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Text(
                '${formatNumber(step + 1, useArabic: useArabic)} / ${formatNumber(totalSteps, useArabic: useArabic)}',
                style:
                    theme.textTheme.labelSmall?.copyWith(color: mutedFg),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor:
                  AppColors.progressTrackOf(context),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Bar ─────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final int step;
  final bool isLastStep, canContinue, canSubmit, saving;
  final VoidCallback onPrevious, onNext, onSubmit;

  const _NavBar({
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                    minimumSize: const Size(52, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_DS.radiusMd)),
                  ),
                  child: const Icon(Icons.arrow_back, size: 22),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 52,
                child: isLastStep
                    ? ElevatedButton(
                        onPressed: canSubmit ? onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.25,  // ← corrige l’alignement vertical
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(_DS.radiusMd)),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('اعتماد الخطة'),
                      )
                    : ElevatedButton(
                        onPressed: canContinue ? onNext : null,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.25,  // ← même correction
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(_DS.radiusMd)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('التالي'),
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
        const SizedBox(height: 20),

        // Icon hero
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.menu_book_rounded, size: 44, color: primary),
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text(
          'بسم الله نبدأ رحلة التدارك',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'سنجمع بعض التواريخ لنحسب تقديراً للأيام الفائتة، ثم نضع خطة يسيرة للقضاء بإذن الله.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: mutedFg, height: 1.7),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 28),

        // Hadith card — prominent, centered
        _HadithCard(
          main: _IC.startMain,
          sub: _IC.startSub,
        ).animate().fadeIn(delay: 350.ms),

        const SizedBox(height: 16),

        // Reassurance — quieter, secondary
        _TipTile(
          icon: Icons.info_outline_rounded,
          text:
              'لا تقلق إن لم تتذكر التواريخ بالضبط — في كل خطوة ستجد خيار التقريب. المهم النيّة الصادقة.',
        ).animate().fadeIn(delay: 550.ms),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Step 1: Dates ────────────────────────────────────────────────────────────
class _StepDates extends StatelessWidget {
  final DateTime? birthDate, bulughDate;
  final bool bulughApprox;
  final ValueChanged<DateTime?> onBirthChanged, onBulughChanged;
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Birth date
        _FieldLabel('تاريخ الميلاد'),
        const SizedBox(height: 8),
        _DateField(
          value: birthDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onChanged: onBirthChanged,
        ),

        const SizedBox(height: 28),

        // Bulugh section header
        Row(
          children: [
            Expanded(
              child: _FieldLabel('تاريخ البلوغ (بداية التكليف)'),
            ),
            _ApproxToggle(
              active: bulughApprox,
              onTap: () => onBulughApproxChanged(!bulughApprox),
            ),
          ],
        ),
        const SizedBox(height: 12),

        AnimatedSwitcher(
          duration: _DS.normal,
          child: bulughApprox
              ? _BulughApproxSection(
                  key: const ValueKey('approx'),
                  birthDate: birthDate,
                  selected: bulughDate,
                  onSelected: onBulughChanged,
                )
              : _BulughExactSection(
                  key: const ValueKey('exact'),
                  birthDate: birthDate,
                  bulughDate: bulughDate,
                  onBulughChanged: onBulughChanged,
                ),
        ),
      ],
    );
  }
}

class _BulughExactSection extends StatelessWidget {
  final DateTime? birthDate, bulughDate;
  final ValueChanged<DateTime?> onBulughChanged;

  const _BulughExactSection({
    super.key,
    required this.birthDate,
    required this.bulughDate,
    required this.onBulughChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DateField(
          hint: 'غالباً بين سن ١٣ و ١٥',
          value: bulughDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onChanged: onBulughChanged,
        ),
        if (birthDate != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [13, 14, 15].map((age) {
              return _Chip(
                label: 'تقدير: $age سنة',
                onTap: () => onBulughChanged(DateTime(
                    birthDate!.year + age,
                    birthDate!.month,
                    birthDate!.day)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _BulughApproxSection extends StatelessWidget {
  final DateTime? birthDate, selected;
  final ValueChanged<DateTime?> onSelected;

  const _BulughApproxSection({
    super.key,
    required this.birthDate,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);

    if (birthDate == null) {
      return _TipTile(
        icon: Icons.info_outline_rounded,
        text: 'أدخل تاريخ الميلاد أولاً لنقترح عليك خيارات مناسبة.',
      );
    }

    final options = [
      (label: 'حوالي ١٢ سنة', age: 12, note: 'تقدير أدنى'),
      (label: 'حوالي ١٣ سنة', age: 13, note: 'شائع'),
      (label: 'حوالي ١٤ سنة', age: 14, note: 'الأكثر شيوعاً ✓'),
      (label: 'حوالي ١٥ سنة', age: 15, note: 'متأخر نسبياً'),
      (label: 'حوالي ١٦ سنة', age: 16, note: 'إن تأخر البلوغ'),
    ];

    return Column(
      children: [
        _HadithCard(main: _IC.bulughHelp, sub: _IC.bulughSub),
        const SizedBox(height: 14),
        ...options.map((opt) {
          final date = DateTime(
              birthDate!.year + opt.age,
              birthDate!.month,
              birthDate!.day);
          final isSelected = selected?.year == date.year &&
              selected?.month == date.month &&
              selected?.day == date.day;
          return _SelectTile(
            label: opt.label,
            sublabel: opt.note,
            isSelected: isSelected,
            primary: primary,
            onTap: () => onSelected(date),
          );
        }),
      ],
    );
  }
}

// ─── Step 2: Commitment ───────────────────────────────────────────────────────
class _StepCommitment extends StatelessWidget {
  final DateTime? bulughDate, commitmentDate;
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
    final mutedFg = AppColors.mutedFgOf(context);

    final diff = bulughDate != null && commitmentDate != null
        ? commitmentDate!.difference(bulughDate!).inDays
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _FieldLabel('تاريخ الالتزام بالصلاة'),
            ),
            _ApproxToggle(
              active: commitmentApprox,
              onTap: () => onApproxChanged(!commitmentApprox),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _HadithCard(main: _IC.commitmentHelp, sub: _IC.commitmentSub),
        const SizedBox(height: 16),

        AnimatedSwitcher(
          duration: _DS.normal,
          child: commitmentApprox
              ? _CommitmentApproxPicker(
                  key: const ValueKey('approx'),
                  bulughDate: bulughDate,
                  selected: commitmentDate,
                  onSelected: onChanged,
                )
              : _CommitmentExactSection(
                  key: const ValueKey('exact'),
                  bulughDate: bulughDate,
                  commitmentDate: commitmentDate,
                  onChanged: onChanged,
                ),
        ),

        if (diff != null && diff > 0) ...[
          const SizedBox(height: 16),
          _InfoStrip(
            icon: Icons.schedule_rounded,
            label:
                'المدة بين البلوغ والالتزام: ${(diff / 365).floor()} سنوات و ${((diff % 365) / 30).floor()} أشهر',
            primary: primary,
          ),
        ],
      ],
    );
  }
}

class _CommitmentExactSection extends StatelessWidget {
  final DateTime? bulughDate, commitmentDate;
  final ValueChanged<DateTime?> onChanged;

  const _CommitmentExactSection({
    super.key,
    required this.bulughDate,
    required this.commitmentDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final now = DateTime.now();
    final chips = [
      ('منذ ٦ أشهر', DateTime(now.year, now.month - 6, now.day)),
      ('منذ سنة', DateTime(now.year - 1, now.month, now.day)),
      ('منذ ٣ سنوات', DateTime(now.year - 3, now.month, now.day)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateField(
          hint: 'التاريخ الذي بدأت بالمحافظة على الصلاة',
          value: commitmentDate,
          firstDate: bulughDate ?? DateTime(1900),
          lastDate: now,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Text('أو اختر تقريباً:',
            style:
                theme.textTheme.labelMedium?.copyWith(color: mutedFg)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((c) {
            final valid = bulughDate == null ||
                c.$2.isAfter(bulughDate!);
            if (!valid) return const SizedBox.shrink();
            return _Chip(
                label: c.$1, onTap: () => onChanged(c.$2));
          }).toList(),
        ),
      ],
    );
  }
}

class _CommitmentApproxPicker extends StatefulWidget {
  final DateTime? bulughDate, selected;
  final ValueChanged<DateTime?> onSelected;

  const _CommitmentApproxPicker({
    super.key,
    required this.bulughDate,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CommitmentApproxPicker> createState() =>
      _CommitmentApproxPickerState();
}

class _CommitmentApproxPickerState extends State<_CommitmentApproxPicker> {
  // true = show preset tiles, false = show year input
  bool _showPresets = true;
  late final TextEditingController _yearCtrl;

  int _labelToYears(String label) {
    if (label.contains('سنة تقريباً')) return 1;
    if (label.contains('سنتين')) return 2;
    if (label.contains('٥')) return 5;
    if (label.contains('١٠')) return 10;
    return 15;
  }

  @override
  void initState() {
    super.initState();
    // If selected is already set and doesn't match a preset, pre-fill year
    _yearCtrl = TextEditingController(
      text: widget.selected?.year.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }

  void _applyYear(String raw) {
    final year = int.tryParse(raw);
    if (year == null) return;
    final now = DateTime.now();
    if (year < 1950 || year > now.year) return;
    final date = DateTime(year, 6, 1); // mid-year approximation
    if (widget.bulughDate != null && date.isBefore(widget.bulughDate!)) return;
    widget.onSelected(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final muted = AppColors.mutedOf(context);
    final border = AppColors.borderOf(context);
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle between presets and year input
        Container(
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(_DS.radiusMd),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _ModeTab(
                label: 'تقدير سريع',
                active: _showPresets,
                primary: primary,
                mutedFg: mutedFg,
                surface: AppColors.surfaceOf(context),
                onTap: () => setState(() => _showPresets = true),
              ),
              _ModeTab(
                label: 'سنة محددة',
                active: !_showPresets,
                primary: primary,
                mutedFg: mutedFg,
                surface: AppColors.surfaceOf(context),
                onTap: () => setState(() => _showPresets = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        AnimatedSwitcher(
          duration: _DS.normal,
          child: _showPresets
              ? Column(
                  key: const ValueKey('presets'),
                  children: _commitmentApproxOptions.map((opt) {
                    final years = _labelToYears(opt.label);
                    final date =
                        DateTime(now.year - years, now.month, now.day);
                    if (widget.bulughDate != null &&
                        date.isBefore(widget.bulughDate!)) {
                      return const SizedBox.shrink();
                    }
                    final isSelected = widget.selected != null &&
                        widget.selected!.year == date.year &&
                        widget.selected!.month == date.month;
                    return _SelectTile(
                      label: opt.label,
                      sublabel: opt.sublabel,
                      isSelected: isSelected,
                      primary: primary,
                      onTap: () => widget.onSelected(date),
                    );
                  }).toList(),
                )
              : Column(
                  key: const ValueKey('yearInput'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أدخل السنة التي التزمت فيها بالصلاة',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: mutedFg),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _yearCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'مثال: ${now.year - 10}',
                              hintStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(color: mutedFg),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(_DS.radiusMd),
                              ),
                            ),
                            onChanged: _applyYear,
                            onSubmitted: _applyYear,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Validation hint
                    if (widget.selected != null && !_showPresets)
                      _InfoStrip(
                        icon: Icons.check_circle_outline_rounded,
                        label:
                            'سيتم احتساب الالتزام منذ منتصف سنة ${widget.selected!.year}',
                        primary: primary,
                      ),
                    if (_yearCtrl.text.isNotEmpty &&
                        (int.tryParse(_yearCtrl.text) == null ||
                            (int.tryParse(_yearCtrl.text) ?? 0) < 1950 ||
                            (int.tryParse(_yearCtrl.text) ?? 9999) >
                                now.year))
                      _TipTile(
                        icon: Icons.warning_amber_rounded,
                        text:
                            'الرجاء إدخال سنة صحيحة بين ١٩٥٠ و ${now.year}.',
                      ),
                    const SizedBox(height: 8),
                    // Quick year shortcuts for common older ranges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final offset in [10, 15, 20, 25, 30])
                          if (widget.bulughDate == null ||
                              DateTime(now.year - offset, 6, 1)
                                  .isAfter(widget.bulughDate!))
                            _Chip(
                              label: '${now.year - offset}',
                              onTap: () {
                                _yearCtrl.text =
                                    '${now.year - offset}';
                                _applyYear('${now.year - offset}');
                              },
                            ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ─── Step 3: Estimate ─────────────────────────────────────────────────────────
class _StepEstimate extends StatelessWidget {
  final DateTime? bulughDate, commitmentDate;
  final bool granularMode;
  final int years, months, days, missedDays;
  final bool useArabic;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<int> onYearsChanged, onMonthsChanged, onDaysChanged,
      onMissedDaysChanged;

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

  int get _total =>
      granularMode ? (years * 365 + months * 30 + days).clamp(0, 999999) : missedDays;

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
    final surface = AppColors.surfaceOf(context);
    final autoCalc = _autoCalcDays;

    return Column(
      children: [
        const SizedBox(height: 16),

        _HadithCard(main: _IC.estimateHelp, sub: _IC.estimateSub),
        const SizedBox(height: 8),
        Text(
          'قدّر بصدق الفترة التي فاتتك فيها الصلاة فعلياً.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: mutedFg, height: 1.6),
          textAlign: TextAlign.center,
        ),

        // Auto-calc banner
        if (autoCalc != null) ...[
          const SizedBox(height: 16),
          _AutoCalcBanner(
            autoCalcDays: autoCalc,
            useArabic: useArabic,
            primary: primary,
            onAccept: () {
              final y = autoCalc ~/ 365;
              final r = autoCalc % 365;
              final m = r ~/ 30;
              final d = r % 30;
              onModeChanged(true);
              onYearsChanged(y);
              onMonthsChanged(m);
              onDaysChanged(d);
            },
          ),
        ],

        const SizedBox(height: 20),

        // Mode toggle
        Container(
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(_DS.radiusMd),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _ModeTab(
                label: 'سنوات / شهور / أيام',
                active: granularMode,
                primary: primary,
                mutedFg: mutedFg,
                surface: surface,
                onTap: () => onModeChanged(true),
              ),
              _ModeTab(
                label: 'عدد الأيام مباشرة',
                active: !granularMode,
                primary: primary,
                mutedFg: mutedFg,
                surface: surface,
                onTap: () => onModeChanged(false),
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

        // Summary row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'إجمالي الأيام',
                value: formatNumber(_total, useArabic: useArabic),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'إجمالي الصلوات',
                value: formatNumber(_total * 5, useArabic: useArabic),
                accent: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _TipTile(
          icon: Icons.auto_awesome_rounded,
          text: _IC.approxOk,
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final Color primary, mutedFg, surface;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.active,
    required this.primary,
    required this.mutedFg,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: _DS.fast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: active ? primary : mutedFg),
          ),
        ),
      ),
    );
  }
}

class _AutoCalcBanner extends StatelessWidget {
  final int autoCalcDays;
  final bool useArabic;
  final Color primary;
  final VoidCallback onAccept;

  const _AutoCalcBanner({
    required this.autoCalcDays,
    required this.useArabic,
    required this.primary,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.12),
            primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_DS.radiusMd),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_fix_high, color: primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حساب تلقائي من التواريخ',
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: primary, fontWeight: FontWeight.w700)),
                Text(
                  '${formatNumber(autoCalcDays, useArabic: useArabic)} يوم — ${formatNumber(autoCalcDays * 5, useArabic: useArabic)} صلاة',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: primary.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(_DS.radiusSm)),
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.08);
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

  static const _presets = [
    (value: 1, label: 'خفيف', hint: 'يوم قضاء يومياً · ٥ صلوات',
        icon: Icons.spa_rounded),
    (value: 2, label: 'معتدل', hint: 'يومان يومياً · ١٠ صلوات',
        icon: Icons.directions_walk_rounded),
    (value: 3, label: 'نشط', hint: 'ثلاثة أيام يومياً · ١٥ صلاة',
        icon: Icons.directions_run_rounded),
    (value: 5, label: 'مكثف', hint: 'خمسة أيام يومياً · ٢٥ صلاة',
        icon: Icons.bolt_rounded),
  ];

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
        const SizedBox(height: 16),
        _HadithCard(main: _IC.generalMain, sub: _IC.generalSub),
        const SizedBox(height: 20),

        ..._presets.map((p) {
          final active = dailyTarget == p.value;
          return GestureDetector(
            onTap: () => onTargetChanged(p.value),
            child: AnimatedContainer(
              duration: _DS.fast,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: active
                    ? primary.withValues(alpha: 0.07)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(_DS.radiusMd),
                border: Border.all(
                    color: active
                        ? primary.withValues(alpha: 0.4)
                        : border,
                    width: active ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: active
                          ? primary.withValues(alpha: 0.13)
                          : muted.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(p.icon,
                        size: 18, color: active ? primary : mutedFg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: active ? primary : null,
                                fontWeight: FontWeight.w600)),
                        Text(p.hint,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: mutedFg)),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: active ? 1 : 0,
                    duration: _DS.fast,
                    child: Icon(Icons.check_circle_rounded,
                        color: primary, size: 20),
                  ),
                ],
              ),
            ),
          );
        }),

        if (daysNeeded > 0) ...[
          const SizedBox(height: 4),
          _InfoStrip(
            icon: Icons.flag_rounded,
            label:
                'بهذا المعدل، ستنهي القضاء خلال ${formatNumber(daysNeeded, useArabic: useArabic)} يوماً',
            primary: primary,
          ),
        ],

        const SizedBox(height: 20),
        _FieldLabel('تاريخ البدء'),
        const SizedBox(height: 8),
        _DateField(
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
        const SizedBox(height: 8),
        Text(
          'راجع البيانات أدناه قبل الاعتماد.',
          style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Review card
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _ReviewRow(
                  label: 'تاريخ الميلاد',
                  value: birthDate != null
                      ? formatArabicDate(dateToIso(birthDate!))
                      : '-'),
              _ReviewRow(
                  label: 'تاريخ البلوغ',
                  value: bulughDate != null
                      ? formatArabicDate(dateToIso(bulughDate!))
                      : '-',
                  isApprox: bulughApprox),
              _ReviewRow(
                  label: 'تاريخ الالتزام',
                  value: commitmentDate != null
                      ? formatArabicDate(dateToIso(commitmentDate!))
                      : '-',
                  isApprox: commitmentApprox),
              _ReviewRow(
                  label: 'الأيام الفائتة',
                  value: '${formatNumber(missedDays, useArabic: useArabic)} يوماً'),
              _ReviewRow(
                  label: 'إجمالي الصلوات',
                  value: '${formatNumber(missedDays * 5, useArabic: useArabic)} صلاة',
                  highlight: true),
              _ReviewRow(
                  label: 'الهدف اليومي',
                  value:
                      '${formatNumber(dailyTarget, useArabic: useArabic)} يوم · ${formatNumber(dailyTarget * 5, useArabic: useArabic)} صلاة'),
              _ReviewRow(
                  label: 'تاريخ البدء',
                  value: formatArabicDate(dateToIso(startDate))),
              if (daysNeeded > 0)
                _ReviewRow(
                    label: 'مدة الإنجاز التقديرية',
                    value:
                        '${formatNumber(daysNeeded, useArabic: useArabic)} يوماً'),
            ],
          ),
        ),

        if (bulughApprox || commitmentApprox) ...[
          const SizedBox(height: 12),
          _TipTile(
            icon: Icons.info_outline_rounded,
            text:
                'البيانات المحددة بعلامة "تقريبي" هي تقديرات مقبولة شرعاً عند عدم المعرفة بالضبط.',
          ),
        ],

        const SizedBox(height: 20),

        // Confirmation
        GestureDetector(
          onTap: () => onConfirmedChanged(!confirmed),
          child: AnimatedContainer(
            duration: _DS.fast,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: confirmed
                  ? primary.withValues(alpha: 0.07)
                  : muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              border: Border.all(
                color: confirmed
                    ? primary.withValues(alpha: 0.4)
                    : border,
                width: confirmed ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: _DS.fast,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: confirmed ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: confirmed ? primary : AppColors.mutedFgOf(context)),
                  ),
                  child: confirmed
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'راجعت البيانات وأؤكد أنها صحيحة بقدر ما أعلم، وأرغب باعتماد الخطة.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  final bool isApprox, highlight;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.isApprox = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Text(label,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
              const Spacer(),
              if (isApprox) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.14),
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
                      fontWeight: FontWeight.w600,
                      color: highlight ? primary : null)),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

// ─── Shared design components ─────────────────────────────────────────────────

/// Large centered hadith/quote card — used once per step, at the top
class _HadithCard extends StatelessWidget {
  final String main, sub;

  const _HadithCard({required this.main, required this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: _DS.cardPad, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.09),
            primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(_DS.radiusMd),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote_rounded,
              size: 22, color: primary.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          Text(
            main,
            style: theme.textTheme.titleSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w700,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: theme.textTheme.bodySmall?.copyWith(
              color: primary.withValues(alpha: 0.75),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Small muted tip row — secondary info, quiet design
class _TipTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(_DS.radiusMd),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 16,
              color: Colors.amber.shade700.withValues(alpha: 0.8)),
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

/// Selectable option tile (approx pickers)
class _SelectTile extends StatelessWidget {
  final String label, sublabel;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  const _SelectTile({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _DS.fast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(_DS.radiusMd),
          border: Border.all(
            color: isSelected
                ? primary.withValues(alpha: 0.45)
                : AppColors.borderOf(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primary : null)),
                  Text(sublabel,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: mutedFg)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: _DS.fast,
              child: isSelected
                  ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey('checked'),
                      color: primary,
                      size: 20)
                  : Icon(Icons.radio_button_unchecked,
                      key: const ValueKey('empty'),
                      color: mutedFg,
                      size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact highlighted stat card
class _StatCard extends StatelessWidget {
  final String label, value;
  final bool accent;

  const _StatCard({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final fg = accent ? primary : AppColors.foregroundOf(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent
            ? primary.withValues(alpha: 0.07)
            : muted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(_DS.radiusMd),
      ),
      child: Column(
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: AppColors.mutedFgOf(context)),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: fg, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Inline info strip (single-line info with icon)
class _InfoStrip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;

  const _InfoStrip(
      {required this.icon, required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(_DS.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: primary)),
          ),
        ],
      ),
    );
  }
}

/// Approx toggle pill (header action)
class _ApproxToggle extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _ApproxToggle({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _DS.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? primary.withValues(alpha: 0.12)
              : AppColors.mutedOf(context).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.help : Icons.help_outline,
              size: 13,
              color: active ? primary : mutedFg,
            ),
            const SizedBox(width: 4),
            Text(
              'لا أتذكر بالضبط؟',
              style: theme.textTheme.labelSmall?.copyWith(
                color: active ? primary : mutedFg,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Field section label
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700));
  }
}

/// Suggestion chip
class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: primary.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(20),
          color: primary.withValues(alpha: 0.05),
        ),
        child: Text(label,
            style: theme.textTheme.labelMedium?.copyWith(color: primary)),
      ),
    );
  }
}

// ─── Date field ───────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String? hint;
  final DateTime? value;
  final DateTime firstDate, lastDate;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    this.hint,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  DateTime _clamp(DateTime d, DateTime mn, DateTime mx) {
    if (d.isBefore(mn)) return mn;
    if (d.isAfter(mx)) return mx;
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = _clamp(value ?? DateTime.now(), firstDate, lastDate);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('ar'),
        );
        onChanged(picked);
      },
      borderRadius: BorderRadius.circular(_DS.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: value != null
                ? primary.withValues(alpha: 0.45)
                : border,
          ),
          borderRadius: BorderRadius.circular(_DS.radiusMd),
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
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: value != null ? null : mutedFg),
              ),
            ),
            Icon(Icons.expand_more_rounded, color: mutedFg, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Number input ─────────────────────────────────────────────────────────────
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
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _NumberInput old) {
    super.didUpdateWidget(old);
    final next = widget.value.toString();
    if (!_ctrl.selection.isValid && _ctrl.text != next) _ctrl.text = next;
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
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