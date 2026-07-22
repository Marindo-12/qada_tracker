import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/approx_options.dart';
import '../../design/design_tokens.dart';
import '../shared/animated_chip.dart';
import '../shared/animated_toggle.dart';
import '../shared/expandable_section.dart';
import '../shared/hover_lift_card.dart';
import '../shared/hover_press_row.dart';
import '../shared/misc_widgets.dart';
import '../shared/select_tile.dart';
import '../shared/tip_tile.dart';
import '../shared/underline_date_field.dart';

/// ─── Step 2: Commitment ───────────────────────────────────────────────────
///
/// Redesigned from the Google Stitch mockup (code.html — "الالتزام الكامل").
/// Keeps the same public API as before (bulughDate, commitmentDate,
/// commitmentApprox, onChanged, onApproxChanged) so it drops straight into
/// setup_screen.dart.
///
/// Adds back — deliberately, since "لا أتذكر التاريخ بالضبط؟" is a very
/// common case here — a quick-estimate helper with two logical fallbacks:
///   1. Preset gaps since puberty (٦ أشهر … منذ مطلع شبابي)
///   2. "أعرف السنة فقط" — year-only entry, since people often remember the
///      year of a life change but not the exact day.
class StepCommitment extends StatefulWidget {
  final DateTime? bulughDate;
  final DateTime? commitmentDate;
  final bool commitmentApprox;
  final ValueChanged<DateTime?> onChanged;
  final ValueChanged<bool> onApproxChanged;

  const StepCommitment({
    super.key,
    required this.bulughDate,
    required this.commitmentDate,
    required this.commitmentApprox,
    required this.onChanged,
    required this.onApproxChanged,
  });

  @override
  State<StepCommitment> createState() => _StepCommitmentState();
}

class _StepCommitmentState extends State<StepCommitment> with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _expandCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: SetupDS.normal,
      value: widget.commitmentApprox ? 1 : 0,
    );
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void didUpdateWidget(covariant StepCommitment old) {
    super.didUpdateWidget(old);
    if (widget.commitmentApprox != old.commitmentApprox) {
      widget.commitmentApprox ? _expandCtrl.forward() : _expandCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _expandCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

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

  void _pickDate(DateTime date) {
    widget.onChanged(date);
    _pulseCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    final diff = widget.bulughDate != null && widget.commitmentDate != null
        ? widget.commitmentDate!.difference(widget.bulughDate!).inDays
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ── Heading ───────────────────────────────────────────────────
        _reveal(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الالتزام الكامل',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'متى بدأت بأداء الصلوات الخمس بانتظام دون انقطاع؟',
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg, height: 1.7),
              ),
            ],
          ),
          start: 0.0,
          end: 0.45,
        ),

        const SizedBox(height: 24),

        // ── Date field (fond blanc forcé) ────────────────────────────
        _reveal(
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) {
              final pulse = Curves.easeOut.transform(
                1 - (_pulseCtrl.value - 0).abs().clamp(0.0, 1.0),
              );
              final glow = _pulseCtrl.isAnimating ? pulse : 0.0;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: UnderlineDateField(
                  label: 'تاريخ الالتزام الكامل',
                  icon: Icons.event_outlined,
                  hint: 'اختر التاريخ',
                  value: widget.commitmentDate,
                  firstDate: widget.bulughDate ?? DateTime(1900),
                  lastDate: DateTime.now(),
                  highlight: glow,
                  onChanged: (d) {
                    if (d != null) _pickDate(d);
                  },
                ),
              );
            },
          ),
          start: 0.1,
          end: 0.5,
        ),

        const SizedBox(height: 18),

        // ── "I don't remember exactly" toggle ────────────────────────
        _reveal(
          HoverPressRow(
            onTap: () => widget.onApproxChanged(!widget.commitmentApprox),
            builder: (context, lift) {
              return Row(
                children: [
                  AnimatedToggle(value: widget.commitmentApprox, onChanged: widget.onApproxChanged),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'لا أتذكر التاريخ بالضبط',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Color.lerp(mutedFg, primary, lift),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          start: 0.15,
          end: 0.55,
        ),

        ExpandableSection(
          controller: _expandCtrl,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _ApproxCommitmentPicker(
              bulughDate: widget.bulughDate,
              selected: widget.commitmentDate,
              onSelected: _pickDate,
            ),
          ),
        ),

        if (diff != null && diff > 0) ...[
          const SizedBox(height: 16),
          InfoStrip(
            icon: Icons.schedule_rounded,
            label: 'المدة بين البلوغ والالتزام: ${(diff / 365).floor()} سنوات و ${((diff % 365) / 30).floor()} أشهر',
            primary: primary,
          ),
        ],

        const SizedBox(height: 24),

        // ── Tip card, with the Stitch "card-lift" hover effect ───────
        _reveal(
          HoverLiftCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SetupDS.cardPad),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                borderRadius: BorderRadius.circular(SetupDS.radiusLg),
                border: Border.all(color: primary.withValues(alpha: 0.06)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(SetupDS.radiusSm),
                    ),
                    child: Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade700, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('لماذا هذا التاريخ؟',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          'يساعدنا هذا التاريخ في حساب الفجوة بين سن البلوغ والالتزام بالصلاة. سيتم إضافة أي صلوات فائتة خلال هذه الفترة إلى جدول القضاء الخاص بك.',
                          style: theme.textTheme.bodySmall?.copyWith(color: mutedFg, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          start: 0.5,
          end: 0.9,
        ),

      ],
    );
  }
}

// ─── "I don't remember exactly" helper: presets or year-only ─────────────
class _ApproxCommitmentPicker extends StatefulWidget {
  final DateTime? bulughDate;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  const _ApproxCommitmentPicker({
    required this.bulughDate,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_ApproxCommitmentPicker> createState() => _ApproxCommitmentPickerState();
}

class _ApproxCommitmentPickerState extends State<_ApproxCommitmentPicker> {
  bool _yearMode = false;
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
    _yearCtrl = TextEditingController(text: widget.selected?.year.toString() ?? '');
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
    final now = DateTime.now();
    final yearError = _yearCtrl.text.isNotEmpty &&
        (int.tryParse(_yearCtrl.text) == null ||
            (int.tryParse(_yearCtrl.text) ?? 0) < 1950 ||
            (int.tryParse(_yearCtrl.text) ?? 9999) > now.year);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode switch: quick presets vs. year-only
        Container(
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(SetupDS.radiusMd),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              ModeTab(
                label: 'تقدير سريع',
                active: !_yearMode,
                primary: primary,
                mutedFg: mutedFg,
                surface: AppColors.surfaceOf(context),
                onTap: () => setState(() => _yearMode = false),
              ),
              ModeTab(
                label: 'أعرف السنة فقط',
                active: _yearMode,
                primary: primary,
                mutedFg: mutedFg,
                surface: AppColors.surfaceOf(context),
                onTap: () => setState(() => _yearMode = true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        AnimatedSwitcher(
          duration: SetupDS.normal,
          child: !_yearMode
              ? Column(
                  key: const ValueKey('presets'),
                  children: commitmentApproxOptions.map((opt) {
                    final years = _labelToYears(opt.label);
                    final date = DateTime(now.year - years, now.month, now.day);
                    if (widget.bulughDate != null && date.isBefore(widget.bulughDate!)) {
                      return const SizedBox.shrink();
                    }
                    final isSelected = widget.selected != null &&
                        widget.selected!.year == date.year &&
                        widget.selected!.month == date.month;
                    return SelectTile(
                      label: opt.label,
                      sublabel: opt.sublabel,
                      isSelected: isSelected,
                      primary: primary,
                      onTap: () => widget.onSelected(date),
                    );
                  }).toList(),
                )
              : Column(
                  key: const ValueKey('yearOnly'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أدخل السنة التي التزمت فيها بالصلاة',
                        style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _yearCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'مثال: ${now.year - 10}',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: mutedFg),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(SetupDS.radiusMd)),
                      ),
                      onChanged: (v) {
                        setState(() {}); // refresh validation hint
                        _applyYear(v);
                      },
                      onSubmitted: _applyYear,
                    ),
                    const SizedBox(height: 10),
                    if (widget.selected != null && _yearMode && !yearError)
                      InfoStrip(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'سيتم احتساب الالتزام منذ منتصف سنة ${widget.selected!.year}',
                        primary: primary,
                      ),
                    if (yearError)
                      const TipTile(
                        icon: Icons.warning_amber_rounded,
                        text: 'الرجاء إدخال سنة صحيحة بين ١٩٥٠ والسنة الحالية.',
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final offset in [10, 15, 20, 25, 30])
                          if (widget.bulughDate == null ||
                              DateTime(now.year - offset, 6, 1).isAfter(widget.bulughDate!))
                            AnimatedChip(
                              label: '${now.year - offset}',
                              selected: widget.selected?.year == now.year - offset,
                              onTap: () {
                                _yearCtrl.text = '${now.year - offset}';
                                setState(() {});
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