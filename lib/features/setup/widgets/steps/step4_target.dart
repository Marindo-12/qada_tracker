import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../data/islamic_content.dart';
import '../../design/design_tokens.dart';
import '../shared/date_field.dart';
import '../shared/hadith_card.dart';
import '../shared/misc_widgets.dart';

/// ─── Step: Daily Target ───────────────────────────────────────────────────
///
/// Redesigned from the Google Stitch mockup (code.html — "حدد هدفك اليومي").
/// Public API kept identical (dailyTarget, missedDays, startDate, notes,
/// useArabic, onTargetChanged, onStartChanged, onNotesChanged) so it drops
/// straight into setup_screen.dart without touching the parent.
///
/// Changes in this pass:
///   - Preset card icon circles no longer use Material 3's
///     secondaryContainer/primaryContainer (which rendered brownish on
///     this color scheme) — they now use the same muted/primary tint
///     pattern as the rest of the app, and the icon itself is smaller.
///   - The notes field's "quick tag" chips were removed. In their place:
///     2 reminder checkboxes as placeholders for the app's real
///     notification system. They're purely visual for now (local state,
///     no callback) until that logic exists — wire them up once it does.
///   - Tapping anywhere outside a focused field now dismisses the
///     keyboard/focus, matching the fix applied in step3.
class StepTarget extends StatefulWidget {
  final int dailyTarget, missedDays;
  final DateTime startDate;
  final String notes;
  final bool useArabic;
  final ValueChanged<int> onTargetChanged;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<String> onNotesChanged;

  const StepTarget({
    super.key,
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
    (value: 1, label: 'خفيف', hint: 'يوم قضاء يومياً · ٥ صلوات', icon: Icons.spa_rounded),
    (value: 2, label: 'معتدل', hint: 'يومان يومياً · ١٠ صلوات', icon: Icons.directions_walk_rounded),
    (value: 3, label: 'نشط', hint: 'ثلاثة أيام يومياً · ١٥ صلاة', icon: Icons.directions_run_rounded),
    (value: 5, label: 'مكثف', hint: 'خمسة أيام يومياً · ٢٥ صلاة', icon: Icons.bolt_rounded),
  ];

  @override
  State<StepTarget> createState() => _StepTargetState();
}

class _StepTargetState extends State<StepTarget> with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _stripPulseCtrl;
  late final TextEditingController _notesCtrl;
  final FocusNode _notesFocus = FocusNode();
  bool _notesFocused = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _stripPulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _notesCtrl = TextEditingController(text: widget.notes);
    _notesFocus.addListener(() {
      setState(() => _notesFocused = _notesFocus.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant StepTarget old) {
    super.didUpdateWidget(old);
    if (widget.notes != old.notes && widget.notes != _notesCtrl.text) {
      _notesCtrl.text = widget.notes;
    }
    if (widget.dailyTarget != old.dailyTarget) {
      _stripPulseCtrl.forward(from: 0).then((_) {
        if (mounted) _stripPulseCtrl.reverse();
      });
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _stripPulseCtrl.dispose();
    _notesCtrl.dispose();
    _notesFocus.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final daysNeeded = widget.dailyTarget > 0 ? (widget.missedDays / widget.dailyTarget).ceil() : 0;

    return GestureDetector(
      // Tapping outside a focused field (e.g. the notes box) dismisses the
      // keyboard/focus glow instead of leaving it stuck.
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── Heading (from the mockup's header section) ──────────────
          _reveal(
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'حدد هدفك اليومي',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر وتيرة القضاء التي تناسب جدولك الحالي للوصول إلى هدفك بانتظام.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg, height: 1.7),
                ),
              ],
            ),
            start: 0.0,
            end: 0.35,
          ),

          const SizedBox(height: 20),
          const HadithCard(main: IslamicContent.generalMain, sub: IslamicContent.generalSub),
          const SizedBox(height: 20),

          // ── Preset cards (glass-card look, hover/press scale) ───────
          ...List.generate(StepTarget._presets.length, (i) {
            final p = StepTarget._presets[i];
            final active = widget.dailyTarget == p.value;
            return _reveal(
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PresetCard(
                  icon: p.icon,
                  label: p.label,
                  hint: p.hint,
                  active: active,
                  onTap: () => widget.onTargetChanged(p.value),
                ),
              ),
              start: 0.1 + i * 0.05,
              end: 0.5 + i * 0.05,
            );
          }),

          if (daysNeeded > 0) ...[
            const SizedBox(height: 4),
            _reveal(
              AnimatedBuilder(
                animation: _stripPulseCtrl,
                builder: (context, child) {
                  final scale = 1 + (_stripPulseCtrl.value * 0.05);
                  return Transform.scale(scale: scale, child: child);
                },
                child: InfoStrip(
                  icon: Icons.flag_rounded,
                  label: 'بهذا المعدل، ستنهي القضاء خلال ${formatNumber(daysNeeded, useArabic: widget.useArabic)} يوماً',
                  primary: primary,
                ),
              ),
              start: 0.45,
              end: 0.8,
            ),
          ],

          const SizedBox(height: 24),

          // ── Start date ────────────────────────────────────────────
          _reveal(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('تاريخ البدء'),
                const SizedBox(height: 8),
                SetupDateField(
                  value: widget.startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  onChanged: (d) => widget.onStartChanged(d!),
                ),
              ],
            ),
            start: 0.5,
            end: 0.85,
          ),

          const SizedBox(height: 16),

          // ── Notes ─────────────────────────────────────────────────
          _reveal(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('ملاحظات (اختياري)'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(SetupDS.radiusLg),
                    border: Border.all(
                      color: _notesFocused ? primary.withValues(alpha: 0.35) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _notesCtrl,
                    focusNode: _notesFocus,
                    maxLines: 3,
                    onChanged: widget.onNotesChanged,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'أوقات الفراغ المناسبة للقضاء...',
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SetupDS.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SetupDS.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SetupDS.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(SetupDS.cardPad),
                    ),
                  ),
                ),
              ],
            ),
            start: 0.55,
            end: 0.9,
          ),

          const SizedBox(height: 16),

          // ── Reminders — placeholder checkboxes ───────────────────
          // Not wired to anything yet: purely visual until the app's
          // real notification system is ready to hook in here.
          _reveal(
            const _RemindersSection(),
            start: 0.65,
            end: 1.0,
          ),
        ],
      ),
    );
  }
}

// ─── Preset card: neutral (non-brown) icon circle + selection state ───────
class _PresetCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool active;
  final VoidCallback onTap;

  const _PresetCard({
    required this.icon,
    required this.label,
    required this.hint,
    required this.active,
    required this.onTap,
  });

  @override
  State<_PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<_PresetCard> {
  bool _pressed = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final active = widget.active;

    // hover:scale-[1.02] active:scale-95 from the mockup, translated to
    // AnimatedScale driven by pointer state.
    final scale = _pressed ? 0.95 : (_hovering ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: SetupDS.fast,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: SetupDS.normal,
            padding: const EdgeInsets.all(SetupDS.cardPad),
            decoration: BoxDecoration(
              color: active ? primary.withValues(alpha: 0.09) : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(SetupDS.radiusLg),
              border: Border.all(
                color: active ? primary.withValues(alpha: 0.3) : primary.withValues(alpha: 0.08),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Neutral muted circle at rest, tinted primary once
                // selected — no more Material 3 secondary/primary
                // container colors (they rendered brownish here), and
                // the icon itself is smaller.
                AnimatedContainer(
                  duration: SetupDS.normal,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: active ? primary.withValues(alpha: 0.14) : muted.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 18, color: active ? primary : mutedFg),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: primary, fontWeight: FontWeight.w700)),
                      Text(widget.hint, style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg)),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: active ? 1 : 0,
                  duration: SetupDS.fast,
                  child: Icon(Icons.check_circle_rounded, color: primary, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reminders section — 2 placeholder checkboxes, no wiring yet ──────────
class _RemindersSection extends StatefulWidget {
  const _RemindersSection();

  @override
  State<_RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends State<_RemindersSection> {
  // Local-only for now — intentionally not reported back to the parent
  // step until the app's real notification system exists to drive this.
  bool _morning = false;
  bool _perPrayer = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('التذكيرات'),
        const SizedBox(height: 4),
        Text(
          'ستُفعَّل هذه الخيارات لاحقاً مع نظام الإشعارات.',
          style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
        ),
        const SizedBox(height: 8),
        _ReminderCheckbox(
          label: 'تذكير صباحي يومي',
          value: _morning,
          onChanged: (v) => setState(() => _morning = v),
        ),
        _ReminderCheckbox(
          label: 'تذكير بعد كل صلاة',
          value: _perPrayer,
          onChanged: (v) => setState(() => _perPrayer = v),
        ),
      ],
    );
  }
}

class _ReminderCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderCheckbox({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(SetupDS.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: SetupDS.fast,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: value ? primary : AppColors.mutedFgOf(context), width: 1.4),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 10),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}