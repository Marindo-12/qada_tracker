import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/islamic_content.dart';
import '../../design/design_tokens.dart';
import '../shared/animated_count.dart';
import '../shared/auto_calc_banner.dart';
import '../shared/tip_tile.dart';

/// ─── Step 3: Estimate ─────────────────────────────────────────────────────
///
/// Redesigned from the Google Stitch mockup ("تقدير الصلوات الفائتة").
/// Keeps the exact same public API as before, so it drops straight into
/// setup_screen.dart with no changes there.
///
/// Additions beyond the mockup, since the wizard already has a bottom
/// nav bar for "التالي" (no duplicate "حفظ التقدير" button needed here):
///   • the stat cards count up/down with an animated number whenever the
///     total changes, instead of jumping instantly
///   • the number fields get a focus glow (a subtle animated border), so
///     it's clear which one is active
class StepEstimate extends StatefulWidget {
  final DateTime? bulughDate, commitmentDate;
  final bool granularMode;
  final int years, months, days, missedDays;
  final bool useArabic;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<int> onYearsChanged, onMonthsChanged, onDaysChanged, onMissedDaysChanged;

  const StepEstimate({
    super.key,
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

  int get _total => granularMode ? (years * 365 + months * 30 + days).clamp(0, 999999) : missedDays;

  int? get _autoCalcDays {
    if (bulughDate == null || commitmentDate == null) return null;
    final diff = commitmentDate!.difference(bulughDate!).inDays;
    return diff > 0 ? diff : null;
  }

  @override
  State<StepEstimate> createState() => _StepEstimateState();
}

class _StepEstimateState extends State<StepEstimate> with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  // Drives the sliding pill behind the "سنوات/أشهر" ↔ "إجمالي الأيام" switch.
  late final AnimationController _modeCtrl;
  // A slow, continuous scale wobble for the hadith card's watermark icon —
  // mirrors the mockup's `group-hover:scale-110` but ambient instead of
  // hover-only so it still reads on touch devices.
  late final AnimationController _watermarkCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _modeCtrl = AnimationController(
      vsync: this,
      duration: SetupDS.normal,
      value: widget.granularMode ? 0 : 1,
    );
    _watermarkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant StepEstimate old) {
    super.didUpdateWidget(old);
    if (widget.granularMode != old.granularMode) {
      _modeCtrl.animateTo(widget.granularMode ? 0 : 1, curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _modeCtrl.dispose();
    _watermarkCtrl.dispose();
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
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final autoCalc = widget._autoCalcDays;

    return Column(
      children: [
        const SizedBox(height: 8),

        // ── Heading ───────────────────────────────────────────────────
        _reveal(
          Column(
            children: [
              Text(
                'تقدير الصلوات الفائتة',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'دعنا نحسب قضاءك بدقة.',
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          start: 0.0,
          end: 0.35,
        ),

        const SizedBox(height: 20),

        // ── Gold-accented hadith card ────────────────────────────────
        _reveal(
          _GoldHadithCard(watermarkCtrl: _watermarkCtrl),
          start: 0.05,
          end: 0.4,
        ),

        if (autoCalc != null) ...[
          const SizedBox(height: 16),
          _reveal(
            AutoCalcBanner(
              autoCalcDays: autoCalc,
              useArabic: widget.useArabic,
              primary: primary,
              onAccept: () {
                final y = autoCalc ~/ 365;
                final r = autoCalc % 365;
                final m = r ~/ 30;
                final d = r % 30;
                widget.onModeChanged(true);
                widget.onYearsChanged(y);
                widget.onMonthsChanged(m);
                widget.onDaysChanged(d);
              },
            ),
            start: 0.1,
            end: 0.45,
          ),
        ],

        const SizedBox(height: 20),

        // ── Sliding pill mode switch ─────────────────────────────────
        _reveal(
          _ModeSwitch(
            controller: _modeCtrl,
            granularMode: widget.granularMode,
            onChanged: widget.onModeChanged,
          ),
          start: 0.15,
          end: 0.5,
        ),

        const SizedBox(height: 20),

        _reveal(
          AnimatedSwitcher(
            duration: SetupDS.normal,
            child: widget.granularMode
                ? Row(
                    key: const ValueKey('ymd'),
                    children: [
                      Expanded(
                        child: _StyledNumberField(
                          label: 'سنوات',
                          value: widget.years,
                          onChanged: widget.onYearsChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StyledNumberField(
                          label: 'أشهر',
                          value: widget.months,
                          max: 11,
                          onChanged: widget.onMonthsChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StyledNumberField(
                          label: 'أيام',
                          value: widget.days,
                          onChanged: widget.onDaysChanged,
                        ),
                      ),
                    ],
                  )
                : _StyledNumberField(
                    key: const ValueKey('total'),
                    label: 'إجمالي الأيام مباشرة',
                    value: widget.missedDays,
                    large: true,
                    onChanged: widget.onMissedDaysChanged,
                  ),
          ),
          start: 0.2,
          end: 0.55,
        ),

        const SizedBox(height: 20),

        // ── Stat cards, with count-up animation ──────────────────────
        _reveal(
          Row(
            children: [
              Expanded(
                child: _PlainStatCard(
                  label: 'إجمالي الأيام',
                  value: widget._total,
                  useArabic: widget.useArabic,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PremiumStatCard(
                  label: 'إجمالي الصلوات',
                  value: widget._total * 5,
                  useArabic: widget.useArabic,
                ),
              ),
            ],
          ),
          start: 0.3,
          end: 0.65,
        ),

        const SizedBox(height: 16),
        _reveal(
          const TipTile(icon: Icons.auto_awesome_rounded, text: IslamicContent.approxOk),
          start: 0.4,
          end: 0.75,
        ),
      ],
    );
  }
}

// ─── Gold-accented hadith card with a faint, ambient watermark icon ───────
class _GoldHadithCard extends StatelessWidget {
  final AnimationController watermarkCtrl;

  const _GoldHadithCard({required this.watermarkCtrl});

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(SetupDS.radiusLg),
        border: Border(right: BorderSide(color: _gold, width: 4)),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            left: -10,
            child: AnimatedBuilder(
              animation: watermarkCtrl,
              builder: (context, child) {
                final scale = 1.0 + (watermarkCtrl.value * 0.15);
                return Transform.scale(scale: scale, child: child);
              },
              child: Icon(Icons.auto_stories_rounded, size: 72, color: primary.withValues(alpha: 0.08)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SetupDS.cardPad),
            child: Text(
              IslamicContent.estimateHelp,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w700,
                height: 1.8,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sliding pill mode switch ──────────────────────────────────────────────
class _ModeSwitch extends StatelessWidget {
  final AnimationController controller;
  final bool granularMode;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({required this.controller, required this.granularMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final track = AppColors.mutedOf(context);
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: track.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(999)),
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final t = curved.value; // 0 = granular (right), 1 = total (left)
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final pillWidth = constraints.maxWidth / 2;
                  return Align(
                    alignment: Alignment.lerp(Alignment.centerRight, Alignment.centerLeft, t)!,
                    child: Container(
                      width: pillWidth,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(true),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            'سنوات / أشهر',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Color.lerp(Colors.white, mutedFg, t),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(false),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            'إجمالي الأيام',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Color.lerp(mutedFg, Colors.white, t),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tinted number field with an animated focus glow ───────────────────────
class _StyledNumberField extends StatefulWidget {
  final String label;
  final int value;
  final int? max;
  final bool large;
  final ValueChanged<int> onChanged;

  const _StyledNumberField({
    super.key,
    required this.label,
    required this.value,
    this.max,
    this.large = false,
    required this.onChanged,
  });

  @override
  State<_StyledNumberField> createState() => _StyledNumberFieldState();
}

class _StyledNumberFieldState extends State<_StyledNumberField> with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  late final AnimationController _focusCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value == 0 ? '' : widget.value.toString());
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _focusCtrl = AnimationController(vsync: this, duration: SetupDS.fast);
  }

  void _onFocusChange() {
    _focusNode.hasFocus ? _focusCtrl.forward() : _focusCtrl.reverse();
  }

  @override
  void didUpdateWidget(covariant _StyledNumberField old) {
    super.didUpdateWidget(old);
    final next = widget.value == 0 ? '' : widget.value.toString();
    if (!_focusNode.hasFocus && _ctrl.text != next) _ctrl.text = next;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _focusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final curved = CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut);

    return Column(
      children: [
        Text(widget.label, style: theme.textTheme.labelMedium?.copyWith(color: mutedFg)),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            return Container(
              height: 80,
              decoration: BoxDecoration(
                color: Color.lerp(primary.withValues(alpha: 0.05), primary.withValues(alpha: 0.08), t),
                borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                border: Border.all(color: Color.lerp(Colors.transparent, primary, t)!, width: 1.5),
                boxShadow: t > 0
                    ? [BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: child,
            );
          },
          child: TextField(
            controller: _ctrl,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: (widget.large ? theme.textTheme.displaySmall : theme.textTheme.headlineSmall)
                ?.copyWith(fontWeight: FontWeight.bold, color: primary),
            decoration: const InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v) ?? 0;
              final clamped = widget.max != null ? parsed.clamp(0, widget.max!) : parsed.clamp(0, 999999);
              widget.onChanged(clamped);
            },
          ),
        ),
      ],
    );
  }
}

// ─── Plain stat card (total days) ──────────────────────────────────────────
class _PlainStatCard extends StatelessWidget {
  final String label;
  final int value;
  final bool useArabic;

  const _PlainStatCard({required this.label, required this.value, required this.useArabic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Container(
      padding: const EdgeInsets.all(SetupDS.cardPad),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(SetupDS.radiusLg),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(color: mutedFg, letterSpacing: 0.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          AnimatedCount(
            value: value,
            useArabic: useArabic,
            style: theme.textTheme.headlineMedium?.copyWith(color: primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─── Premium stat card (total prayers) — primary bg + gold text ────────────
class _PremiumStatCard extends StatelessWidget {
  final String label;
  final int value;
  final bool useArabic;

  const _PremiumStatCard({required this.label, required this.value, required this.useArabic});

  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(SetupDS.cardPad),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(SetupDS.radiusLg),
        boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.8), letterSpacing: 0.6),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              AnimatedCount(
                value: value,
                useArabic: useArabic,
                style: theme.textTheme.headlineMedium?.copyWith(color: _gold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}