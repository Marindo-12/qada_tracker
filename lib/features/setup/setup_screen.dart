// lib/features/setup/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import '../../core/navigation/app_router.dart';

import 'design/design_tokens.dart';
import 'widgets/step_header.dart';
import 'widgets/nav_bar.dart';
import 'widgets/steps/step0_intro.dart';
import 'widgets/steps/step1_dates.dart';
import 'widgets/steps/step2_commitment.dart';
import 'widgets/steps/step3_estimate.dart';
import 'widgets/steps/step4_target.dart';
import 'widgets/steps/step5_review.dart';

// ─── Main Setup Screen ────────────────────────────────────────────────────────
class SetupScreen extends ConsumerStatefulWidget {
  final PlanTableData? initialPlan;
  const SetupScreen({super.key, this.initialPlan});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _step = 0;
  static const int _totalSteps = 7;

  DateTime? _birthDate;
  DateTime? _bulughDate;
  bool _bulughApprox = false;
  DateTime? _commitmentDate;
  bool _commitmentApprox = false;
  int _missedDays = 1;
  int _dailyTarget = 1;
  DateTime _startDate = DateTime.now();
  String _notes = '';
  NotificationPreferences _notificationPreferences =
      const NotificationPreferences();
  int _years = 0, _months = 0, _days = 0;
  bool _reviewConfirmed = false;
  bool _saving = false;

  int get _granularTotal => (_years * 365) + (_months * 30) + _days;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
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
    // On ne force plus de mode, le plan chargé utilise directement _missedDays.
    // Les champs années/mois/jours peuvent être recalculés si nécessaire.
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationPreferences =
          QadaNotificationService.loadPreferences(prefs);
    });
  }

  static const _stepTitles = [
    'مقدمة',
    'التواريخ الأساسية',
    'تاريخ الالتزام',
    'تقدير الأيام',
    'احتياج القضاء',
    'بداية الخطة',
    'مراجعة',
  ];

  bool _canProceed() {
    switch (_step) {
      case 1:
        return _birthDate != null && _bulughDate != null;
      case 2:
        return _commitmentDate != null;
      case 3:
        // Maintenant seule la saisie granulaire existe, on vérifie qu’il y a au moins un jour.
        return _granularTotal > 0;
      case 4:
        return _dailyTarget >= 1;
      case 5:
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_step == 3) {
      // Calcule automatiquement _missedDays à partir des champs années/mois/jours.
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
    final prefs = await SharedPreferences.getInstance();
    await QadaNotificationService.saveAndSchedule(
      prefs: prefs,
      preferences: _notificationPreferences,
      dailyTarget: _dailyTarget,
    );
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
        return const StepIntro();
      case 1:
        return StepDates(
          birthDate: _birthDate,
          bulughDate: _bulughDate,
          bulughApprox: _bulughApprox,
          onBirthChanged: (d) => setState(() => _birthDate = d),
          onBulughChanged: (d) => setState(() => _bulughDate = d),
          onBulughApproxChanged: (v) => setState(() => _bulughApprox = v),
        );
      case 2:
        return StepCommitment(
          bulughDate: _bulughDate,
          commitmentDate: _commitmentDate,
          commitmentApprox: _commitmentApprox,
          onChanged: (d) => setState(() => _commitmentDate = d),
          onApproxChanged: (v) => setState(() => _commitmentApprox = v),
        );
      case 3:
        return StepEstimate(
          bulughDate: _bulughDate,
          commitmentDate: _commitmentDate,
          years: _years,
          months: _months,
          days: _days,
          missedDays: _missedDays,
          useArabic: useArabic,
          onYearsChanged: (v) => setState(() => _years = v),
          onMonthsChanged: (v) => setState(() => _months = v),
          onDaysChanged: (v) => setState(() => _days = v),
        );
      case 4:
        return StepTarget(
          page: StepTargetPage.needs,
          dailyTarget: _dailyTarget,
          missedDays: _missedDays,
          startDate: _startDate,
          notes: _notes,
          notificationPreferences: _notificationPreferences,
          useArabic: useArabic,
          onTargetChanged: (v) => setState(() => _dailyTarget = v),
          onStartChanged: (d) => setState(() => _startDate = d),
          onNotesChanged: (v) => setState(() => _notes = v),
          onNotificationPreferencesChanged: (v) =>
              setState(() => _notificationPreferences = v),
        );
      case 5:
        return StepTarget(
          page: StepTargetPage.schedule,
          dailyTarget: _dailyTarget,
          missedDays: _missedDays,
          startDate: _startDate,
          notes: _notes,
          notificationPreferences: _notificationPreferences,
          useArabic: useArabic,
          onTargetChanged: (v) => setState(() => _dailyTarget = v),
          onStartChanged: (d) => setState(() => _startDate = d),
          onNotesChanged: (v) => setState(() => _notes = v),
          onNotificationPreferencesChanged: (v) =>
              setState(() => _notificationPreferences = v),
        );
      case 6:
        return StepReview(
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
          child: SetupStepHeader(
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
                duration: SetupDS.normal,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
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
          SetupNavBar(
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
