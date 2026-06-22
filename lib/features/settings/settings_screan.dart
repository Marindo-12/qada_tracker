// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift/drift.dart' hide Column;

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import '../setup/setup_screan.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final useArabic = ref.watch(digitStyleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات', style: theme.textTheme.titleLarge),
      ),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (plan) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Digit Style ──────────────────────────────────────────────
            _SectionCard(
              icon: Icons.translate,
              title: 'شكل الأرقام',
              subtitle: 'اختر طريقة عرض الأرقام في التطبيق',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _DigitOption(
                        label: 'عربية',
                        sample: '٠ ١ ٢ ٣',
                        active: useArabic,
                        onTap: () =>
                            ref.read(digitStyleProvider.notifier).set(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DigitOption(
                        label: 'إنجليزية',
                        sample: '0 1 2 3',
                        active: !useArabic,
                        onTap: () =>
                            ref.read(digitStyleProvider.notifier).set(false),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // ─── Theme ────────────────────────────────────────────────────
            _SectionCard(
              icon: Icons.contrast,
              title: 'المظهر',
              subtitle: 'اختر وضع ألوان التطبيق',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ThemeOption(
                        icon: Icons.phone_android,
                        label: 'تلقائي',
                        active: themeMode == ThemeMode.system,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .set(ThemeMode.system),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ThemeOption(
                        icon: Icons.light_mode_outlined,
                        label: 'فاتح',
                        active: themeMode == ThemeMode.light,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .set(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ThemeOption(
                        icon: Icons.dark_mode_outlined,
                        label: 'داكن',
                        active: themeMode == ThemeMode.dark,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .set(ThemeMode.dark),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            if (plan == null) ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.settings,
                        size: 48, color: AppColors.mutedFgOf(context)),
                    const SizedBox(height: 12),
                    Text('لا توجد خطة مفعلة حالياً.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.mutedFgOf(context))),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SetupScreen()),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('إنشاء خطة جديدة'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ─── Daily Target ──────────────────────────────────────────
              _SectionCard(
                icon: Icons.track_changes,
                title: 'الروتين اليومي',
                subtitle: 'عدد أيام القضاء التي تنوي صلاتها كل يوم',
                child: _DailyTargetEditor(plan: plan),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // ─── Plan Details ──────────────────────────────────────────
              _SectionCard(
                icon: Icons.info_outline,
                title: 'تفاصيل الخطة',
                trailing: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SetupScreen(initialPlan: plan),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('تعديل'),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.cake_outlined,
                      label: 'تاريخ البلوغ',
                      value: formatArabicDate(plan.bulughDate,
                          pattern: 'MMM yyyy'),
                    ),
                    const Divider(height: 1, indent: 16),
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'تاريخ الالتزام',
                      value: formatArabicDate(plan.commitmentDate,
                          pattern: 'MMM yyyy'),
                    ),
                    const Divider(height: 1, indent: 16),
                    _DetailRow(
                      icon: Icons.tag,
                      label: 'الأيام الفائتة',
                      value:
                          '${formatNumber(plan.missedDays, useArabic: useArabic)} يوماً',
                    ),
                    const Divider(height: 1, indent: 16),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'تاريخ البدء',
                      value: formatArabicDate(plan.startDate,
                          pattern: 'dd MMMM yyyy'),
                    ),
                    if (plan.notes != null && plan.notes!.isNotEmpty) ...[
                      const Divider(height: 1, indent: 16),
                      _DetailRow(
                        icon: Icons.notes,
                        label: 'ملاحظات',
                        value: plan.notes!,
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              // ─── About ────────────────────────────────────────────────
              const _SectionCard(
                icon: Icons.help_outline,
                title: 'عن التطبيق',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.app_settings_alt,
                      label: 'الإصدار',
                      value: '1.0.0',
                    ),
                    Divider(height: 1, indent: 16),
                    _DetailRow(
                      icon: Icons.favorite_outline,
                      label: 'تطبيق مجاني بالكامل',
                      value: 'بدون إعلانات',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              // ─── Danger Zone ──────────────────────────────────────────
              Card(
                color: AppColors.destructive.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: AppColors.destructive.withValues(alpha: 0.2),
                      width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('منطقة الخطر',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: AppColors.destructive)),
                      const SizedBox(height: 4),
                      Text('إجراءات لا يمكن التراجع عنها',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.destructive
                                  .withValues(alpha: 0.7))),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmReset(context, ref),
                          icon: const Icon(Icons.delete_forever,
                              color: AppColors.destructive),
                          label: const Text('إعادة تعيين الخطة بالكامل',
                              style: TextStyle(color: AppColors.destructive)),
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: AppColors.destructive),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة التعيين؟',
            style: TextStyle(color: AppColors.destructive)),
        content: const Text(
          'هذا الإجراء سيحذف خطتك الحالية وجميع السجلات والإنجازات السابقة. لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive),
            child: const Text('نعم، احذف كل شيء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final planDao = ref.read(planDaoProvider);
      final logDao = ref.read(prayerLogDaoProvider);
      await logDao.deleteAll();
      await planDao.resetPlan();
      ref.invalidate(planProvider);
      ref.invalidate(summaryProvider);
      ref.invalidate(streakProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(todayLogsProvider);
      ref.invalidate(calendarDataProvider);
    }
  }
}

// ─── Daily Target Editor ──────────────────────────────────────────────────────
class _DailyTargetEditor extends ConsumerStatefulWidget {
  final PlanTableData plan;
  const _DailyTargetEditor({required this.plan});

  @override
  ConsumerState<_DailyTargetEditor> createState() => _DailyTargetEditorState();
}

class _DailyTargetEditorState extends ConsumerState<_DailyTargetEditor> {
  late int _target;
  bool _saving = false;

  static const _presets = [
    {'value': 1, 'label': 'خفيف', 'hint': 'يوم قضاء يومياً (٥ صلوات)'},
    {'value': 2, 'label': 'معتدل', 'hint': 'يومان يومياً (١٠ صلوات)'},
    {'value': 3, 'label': 'نشط', 'hint': 'ثلاثة أيام يومياً (١٥ صلاة)'},
    {'value': 5, 'label': 'مكثف', 'hint': 'خمسة أيام يومياً (٢٥ صلاة)'},
  ];

  @override
  void initState() {
    super.initState();
    _target = widget.plan.dailyTarget;
  }

  Future<void> _save(int newTarget) async {
    setState(() {
      _target = newTarget;
      _saving = true;
    });
    final dao = ref.read(planDaoProvider);
    await dao.upsertPlan(PlanTableCompanion(
      birthDate: Value(widget.plan.birthDate),
      bulughDate: Value(widget.plan.bulughDate),
      commitmentDate: Value(widget.plan.commitmentDate),
      missedDays: Value(widget.plan.missedDays),
      dailyTarget: Value(newTarget),
      startDate: Value(widget.plan.startDate),
      notes: Value(widget.plan.notes),
    ));
    ref.invalidate(planProvider);
    ref.invalidate(summaryProvider);
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useArabic = ref.watch(digitStyleProvider);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الهدف الحالي',
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
                  const SizedBox(height: 2),
                  Text(
                    '${formatNumber(_target, useArabic: useArabic)} يوم قضاء (${formatNumber(_target * 5, useArabic: useArabic)} صلاة)',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              Row(
                children: [
                  _CountBtn(
                    icon: Icons.remove,
                    enabled: _target > 1 && !_saving,
                    onTap: () => _save(_target - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            formatNumber(_target, useArabic: useArabic),
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                  ),
                  _CountBtn(
                    icon: Icons.add,
                    enabled: _target < 50 && !_saving,
                    color: primary,
                    onTap: () => _save(_target + 1),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          Text('أو اختر روتيناً جاهزاً:',
              style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
          const SizedBox(height: 8),

          ..._presets.map((p) {
            final val = p['value'] as int;
            final active = _target == val;
            return GestureDetector(
              onTap: () => _save(val),
              child: AnimatedContainer(
                duration: 200.ms,
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active
                        ? primary.withValues(alpha: 0.4)
                        : border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['label'] as String,
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(color: active ? primary : null)),
                          Text(p['hint'] as String,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: mutedFg)),
                        ],
                      ),
                    ),
                    if (active) Icon(Icons.check, color: primary, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CountBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _CountBtn({
    required this.icon,
    required this.enabled,
    this.color = AppColors.mutedFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: enabled
                  ? color.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon,
            size: 16, color: enabled ? color : color.withValues(alpha: 0.3)),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: primary)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: mutedFg)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: mutedFg),
          const SizedBox(width: 12),
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg)),
          const Spacer(),
          Text(value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DigitOption extends StatelessWidget {
  final String label;
  final String sample;
  final bool active;
  final VoidCallback onTap;

  const _DigitOption({
    required this.label,
    required this.sample,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active
              ? primary.withValues(alpha: 0.08)
              : muted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? primary.withValues(alpha: 0.4) : border,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: active ? primary : null)),
                if (active) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check, color: primary, size: 14),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(sample,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: mutedFg, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

// ─── Theme Option : version compacte pour affichage en Row ───────────────────
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final foreground = AppColors.foregroundOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? primary.withValues(alpha: 0.08)
              : muted.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? primary.withValues(alpha: 0.4) : border,
            width: active ? 2 : 1,
          ),
        ),
        // Centré verticalement : icône au dessus, label en dessous
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? primary : mutedFg,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: active ? primary : foreground,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}