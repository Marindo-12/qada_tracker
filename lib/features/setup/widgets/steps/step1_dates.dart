import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../data/approx_options.dart';
import '../../design/design_tokens.dart';

/// ─── Step 1: Dates ───────────────────────────────────────────────────────
///
/// Redesigned from the Google Stitch mockup (code.html).
/// All motion here is hand-built with [AnimationController] + [Tween] +
/// [AnimatedBuilder] (no flutter_animate), as requested:
///   • a staggered fade/slide-up entrance for each section
///   • a slow, continuous "floating" bob for the hero avatar
///   • an expand/collapse animation for the quick-select puberty helper
///   • press + hover "lift" feedback on the age chips and the toggle
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
  // Drives the slow up/down "floating" bob of the hero avatar.
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatTween;
  // Drives the expand/collapse of the quick-select puberty helper.
  late final AnimationController _expandCtrl;

  // Briefly highlights the puberty field's border after a quick pick,
  // mirroring the JS pulse in the original Stitch mockup.
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _floatTween = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

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
    _floatCtrl.dispose();
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
              AnimatedBuilder(
                animation: _floatTween,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatTween.value),
                    child: child,
                  );
                },
                child: Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha: 0.12), width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppColors.mutedOf(context).withValues(alpha: 0.4),
                      child: Image.asset(
                        'assets/icon/man-icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            Icon(Icons.person_rounded, size: 56, color: primary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                _UnderlineDateField(
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
                    return _UnderlineDateField(
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
                _HoverPress(
                  onTap: () => widget.onBulughApproxChanged(!widget.bulughApprox),
                  builder: (context, lift) {
                    return Row(
                      children: [
                        _AnimatedToggle(
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
                _ExpandableSection(
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

// ─── Underline-style date field (matches the Stitch mockup) ───────────────
class _UnderlineDateField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final DateTime? value;
  final DateTime firstDate, lastDate;
  final double highlight; // 0..1, transient pulse after a quick-pick
  final ValueChanged<DateTime?> onChanged;

  const _UnderlineDateField({
    required this.label,
    this.hint,
    required this.icon,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.highlight = 0,
  });

  DateTime _clamp(DateTime d, DateTime mn, DateTime mx) {
    if (d.isBefore(mn)) return mn;
    if (d.isAfter(mx)) return mx;
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);
    final initial = _clamp(value ?? DateTime.now(), firstDate, lastDate);

    final borderColor = Color.lerp(
      value != null ? primary.withValues(alpha: 0.5) : border,
      primary,
      highlight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: mutedFg,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: firstDate,
              lastDate: lastDate,
              locale: const Locale('ar'),
            );
            if (picked != null) onChanged(picked);
          },
          child: AnimatedContainer(
            duration: SetupDS.fast,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor!, width: highlight > 0 ? 2 : 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? formatArabicDate(dateToIso(value!)) : (hint ?? 'اختر تاريخاً'),
                    style: theme.textTheme.bodyLarge?.copyWith(color: value != null ? null : mutedFg),
                  ),
                ),
                Icon(icon, size: 20, color: value != null ? primary : mutedFg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Expandable section (height + fade), controller-driven ────────────────
class _ExpandableSection extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _ExpandableSection({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: curved.value,
            child: Opacity(
              opacity: curved.value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ─── Custom animated toggle switch ─────────────────────────────────────────
class _AnimatedToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedToggle({required this.value, required this.onChanged});

  @override
  State<_AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<_AnimatedToggle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SetupDS.fast,
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedToggle old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final track = AppColors.mutedOf(context);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final t = curved.value;
          return Container(
            width: 44,
            height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Color.lerp(track.withValues(alpha: 0.6), primary, t),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Align(
              alignment: Alignment.lerp(Alignment.centerRight, Alignment.centerLeft, t)!,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Hover/press "lift" wrapper (used for the toggle row) ─────────────────
class _HoverPress extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(BuildContext context, double lift) builder;

  const _HoverPress({required this.onTap, required this.builder});

  @override
  State<_HoverPress> createState() => _HoverPressState();
}

class _HoverPressState extends State<_HoverPress> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SetupDS.fast);
    _lift = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setTarget(double target) => _controller.animateTo(target, curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setTarget(0.5),
      onExit: (_) => _setTarget(0),
      child: GestureDetector(
        onTapDown: (_) => _setTarget(1),
        onTapUp: (_) => _setTarget(0.5),
        onTapCancel: () => _setTarget(0),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _lift,
          builder: (context, _) => widget.builder(context, _lift.value),
        ),
      ),
    );
  }
}

// ─── Age chip with press + hover scale feedback ────────────────────────────
class _AgeChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AgeChip({required this.label, required this.selected, required this.onTap});

  @override
  State<_AgeChip> createState() => _AgeChipState();
}

class _AgeChipState extends State<_AgeChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SetupDS.fast);
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _controller.animateTo(0.4),
      onExit: (_) => _controller.animateTo(0),
      child: GestureDetector(
        onTapDown: (_) => _controller.animateTo(1),
        onTapUp: (_) => _controller.animateTo(0),
        onTapCancel: () => _controller.animateTo(0),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) {
            return Transform.scale(scale: _scale.value, child: child);
          },
          child: AnimatedContainer(
            duration: SetupDS.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selected ? primary.withValues(alpha: 0.08) : Colors.transparent,
              border: Border.all(color: widget.selected ? primary : border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                color: widget.selected ? primary : mutedFg,
              ),
            ),
          ),
        ),
      ),
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
            border: Border(right: BorderSide(color: Colors.amber.shade600, width: 4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: Colors.amber.shade700),
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
            return _AgeChip(
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
            return _AgeChip(
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