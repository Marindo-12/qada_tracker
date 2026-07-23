import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../data/approx_options.dart';
import '../../design/design_tokens.dart';
import '../shared/animated_chip.dart';
import '../shared/animated_toggle.dart';
import '../shared/expandable_section.dart';
import '../shared/hover_press_row.dart';
import '../shared/underline_date_field.dart';

/// ─── Step 1: Dates ───────────────────────────────────────────────────────
///
/// Redesigned from the Google Stitch mockup (code.html).
/// All motion here is hand-built with [AnimationController] + [Tween] +
/// [AnimatedBuilder] (no flutter_animate). Shared pieces (underline field,
/// toggle, expandable section, chip, hover row) now live under
/// widgets/shared/ so Step 2 can reuse them too.
class StepDates extends StatefulWidget {
  final DateTime? birthDate;
  final DateTime? bulughDate;
  final bool bulughApprox;
  final ValueChanged<DateTime?> onBirthChanged;
  final ValueChanged<DateTime?> onBulughChanged;
  final ValueChanged<bool> onBulughApproxChanged;

  const StepDates({
    super.key,
    required this.birthDate,
    required this.bulughDate,
    required this.bulughApprox,
    required this.onBirthChanged,
    required this.onBulughChanged,
    required this.onBulughApproxChanged,
  });

  @override
  State<StepDates> createState() => _StepDatesState();
}

class _StepDatesState extends State<StepDates> with TickerProviderStateMixin {
  // Drives the staggered entrance of each section on first build.
  late final AnimationController _entranceCtrl;
  // Drives the expand/collapse of the quick-select puberty helper.
  late final AnimationController _expandCtrl;

  // Briefly highlights the puberty field's border after a quick pick.
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    _expandCtrl = AnimationController(
      vsync: this,
      duration: SetupDS.normal,
      value: widget.bulughApprox ? 1 : 0,
    );

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void didUpdateWidget(covariant StepDates old) {
    super.didUpdateWidget(old);
    if (widget.bulughApprox != old.bulughApprox) {
      widget.bulughApprox ? _expandCtrl.forward() : _expandCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _expandCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  /// Wraps [child] with a fade + slide-up reveal, timed to a slice of
  /// [_entranceCtrl]'s 0..1 run (staggering multiple sections from one
  /// controller instead of spinning up a controller per widget).
  Widget _reveal(Widget child, {required double start, required double end}) {
    final curved = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Interval(start, end, curve: SetupDS.entrance),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, c) {
        return Opacity(
          opacity: curved.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - curved.value.clamp(0.0, 1.0)) * 18),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  void _setPubertyFromAge(int age) {
    if (widget.birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال تاريخ ميلادك أولاً')),
      );
      return;
    }
    final b = widget.birthDate!;
    widget.onBulughChanged(DateTime(b.year + age, b.month, b.day));
    _pulseCtrl.forward(from: 0);
  }

  bool _isAgeSelected(int age) {
    if (widget.birthDate == null || widget.bulughDate == null) return false;
    final b = widget.birthDate!;
    final candidate = DateTime(b.year + age, b.month, b.day);
    return candidate.year == widget.bulughDate!.year &&
        candidate.month == widget.bulughDate!.month &&
        candidate.day == widget.bulughDate!.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ── Hero avatar + heading ──────────────────────────────────────
        _reveal(
          Column(
            children: [
              Text(
                'التأسيس',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'لحساب صلواتك الفائتة بدقة، نحتاج أولاً إلى تحديد متى بدأت التزاماتك الروحية.',
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg, height: 1.7),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          start: 0.0,
          end: 0.55,
        ),

        const SizedBox(height: 28),

        // ── Form canvas ────────────────────────────────────────────────
        _reveal(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SetupDS.cardPad),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(SetupDS.radiusLg),
              border: Border.all(color: primary.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UnderlineDateField(
                  label: 'تاريخ الميلاد',
                  icon: Icons.cake_outlined,
                  value: widget.birthDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  onChanged: widget.onBirthChanged,
                ),
                const SizedBox(height: 26),
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    final pulse = Curves.easeOut.transform(
                      1 - (_pulseCtrl.value - 0).abs().clamp(0.0, 1.0),
                    );
                    final glow = _pulseCtrl.isAnimating ? pulse : 0.0;
                    return UnderlineDateField(
                      label: 'تاريخ البلوغ',
                      icon: Icons.history_edu_outlined,
                      hint: 'غالباً بين سن ١٢ و ١٥',
                      value: widget.bulughDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      highlight: glow,
                      onChanged: widget.onBulughChanged,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Toggle helper
                HoverPressRow(
                  onTap: () => widget.onBulughApproxChanged(!widget.bulughApprox),
                  builder: (context, lift) {
                    return Row(
                      children: [
                        AnimatedToggle(
                          value: widget.bulughApprox,
                          onChanged: widget.onBulughApproxChanged,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'لا أتذكر تاريخ بلوغي',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Color.lerp(mutedFg, primary, lift),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Expandable quick-select section
                ExpandableSection(
                  controller: _expandCtrl,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _QuickSelectPuberty(
                      hasBirthDate: widget.birthDate != null,
                      isAgeSelected: _isAgeSelected,
                      onPickAge: _setPubertyFromAge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          start: 0.2,
          end: 0.85,
        ),

        const SizedBox(height: 14),
        _reveal(
          Text(
            'بياناتك مخزنة محلياً وتظل خاصة بك.',
            style: theme.textTheme.labelSmall?.copyWith(color: mutedFg),
            textAlign: TextAlign.center,
          ),
          start: 0.5,
          end: 1.0,
        ),
      ],
    );
  }
}

// ─── Quick-select puberty helper (male/female age presets) ────────────────
class _QuickSelectPuberty extends StatelessWidget {
  final bool hasBirthDate;
  final bool Function(int age) isAgeSelected;
  final ValueChanged<int> onPickAge;

  const _QuickSelectPuberty({
    required this.hasBirthDate,
    required this.isAgeSelected,
    required this.onPickAge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.mutedOf(context).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(SetupDS.radiusSm),
            border: const Border(right: BorderSide(color: AppColors.tertiaryContainer, width: 4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.tertiaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'يمكنك اختيار العمر التقريبي للبلوغ. الخيار الفقهي الشائع في حال عدم المعرفة هو ١٥ عاماً هجرياً.',
                  style: theme.textTheme.bodySmall?.copyWith(color: mutedFg, height: 1.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Male
        Row(
          children: [
            Icon(Icons.male_rounded, size: 16, color: primary),
            const SizedBox(width: 4),
            Text('ذكر',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: primary, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text('تذكر أول مرة حدث فيها الاحتلام.',
              style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: malePubertyAges.map((age) {
            return AnimatedChip(
              label: age == 15 ? '١٥ سنة (الافتراضي)' : '${formatNumber(age, useArabic: true)} سنة',
              selected: isAgeSelected(age),
              onTap: () => onPickAge(age),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Female
        Row(
          children: [
            Icon(Icons.female_rounded, size: 16, color: primary),
            const SizedBox(width: 4),
            Text('أنثى',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: primary, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text('تذكري أول مرة نزل فيها دم الحيض.',
              style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: femalePubertyAges.map((age) {
            return AnimatedChip(
              label: '${formatNumber(age, useArabic: true)} سنوات',
              selected: isAgeSelected(age),
              onTap: () => onPickAge(age),
            );
          }).toList(),
        ),

        if (!hasBirthDate) ...[
          const SizedBox(height: 12),
          Text(
            'أدخل تاريخ الميلاد أولاً لتفعيل التقدير السريع.',
            style: theme.textTheme.bodySmall?.copyWith(color: mutedFg, fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}
