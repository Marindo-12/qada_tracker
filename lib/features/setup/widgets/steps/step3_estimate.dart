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
/// Only one entry mode now: years / months / days. The old "total days"
/// mode and its switch were removed per request — if an existing plan was
/// saved with only a total (granularMode == false), it's converted back
/// into years/months/days once on mount so editing an old plan still shows
/// sensible numbers instead of zeros.
class StepEstimate extends StatefulWidget {
  final DateTime? bulughDate, commitmentDate;
  final bool granularMode;
  final int years, months, days, missedDays;
  final bool useArabic;
  final ValueChanged<bool>? onModeChanged;
  final ValueChanged<int> onYearsChanged, onMonthsChanged, onDaysChanged;
  final ValueChanged<int>? onMissedDaysChanged;

  const StepEstimate({
    super.key,
    required this.bulughDate,
    required this.commitmentDate,
    this.granularMode = true,
    required this.years,
    required this.months,
    required this.days,
    required this.missedDays,
    this.useArabic = false,
    this.onModeChanged,
    required this.onYearsChanged,
    required this.onMonthsChanged,
    required this.onDaysChanged,
    this.onMissedDaysChanged,
  });

  int get _total => (years * 365 + months * 30 + days).clamp(0, 999999);

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
  // A slow, continuous scale wobble for the hadith card's watermark icon —
  // mirrors the mockup's `group-hover:scale-110` but ambient instead of
  // hover-only so it still reads on touch devices.
  late final AnimationController _watermarkCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _watermarkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat(reverse: true);

    // Back-compat: an older plan saved with only a total (granularMode ==
    // false) has years/months/days at 0. Convert it once so the fields
    // don't show zero for an existing estimate.
    if (!widget.granularMode && widget.missedDays > 0 && widget._total == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final total = widget.missedDays;
        final y = total ~/ 365;
        final r = total % 365;
        final m = r ~/ 30;
        final d = r % 30;
        widget.onYearsChanged(y);
        widget.onMonthsChanged(m);
        widget.onDaysChanged(d);
        widget.onModeChanged?.call(true);
      });
    } else if (!widget.granularMode) {
      // Already-zero total, or fields already populated — just flip the
      // flag so downstream logic treats this step as the single source
      // of truth for missedDays going forward.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onModeChanged?.call(true);
      });
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
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

    return GestureDetector(
      // Tapping anywhere outside a number field dismisses the keyboard and
      // clears its focus glow — without this, the caret/focus state can
      // linger since nothing else in the step claims focus on tap.
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── Heading ───────────────────────────────────────────────
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

          // ── Gold-accented hadith card ────────────────────────────
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
                  widget.onYearsChanged(y);
                  widget.onMonthsChanged(m);
                  widget.onDaysChanged(d);
                },
              ),
              start: 0.1,
              end: 0.45,
            ),
          ],

          const SizedBox(height: 24),

          // ── Plain label (no switch — only one entry mode now) ────
          _reveal(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سنوات / أشهر / أيام',
                style: theme.textTheme.labelMedium?.copyWith(color: mutedFg, fontWeight: FontWeight.w700),
              ),
            ),
            start: 0.15,
            end: 0.5,
          ),

          const SizedBox(height: 10),

          _reveal(
            Row(
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
            ),
            start: 0.2,
            end: 0.55,
          ),

          const SizedBox(height: 20),

          // ── Stat cards, with count-up animation ──────────────────
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
      ),
    );
  }
}

// ─── Gold-accented hadith card with a faint, ambient watermark icon ───────
class _GoldHadithCard extends StatelessWidget {
  final AnimationController watermarkCtrl;

  const _GoldHadithCard({required this.watermarkCtrl});

  static const _gold = Color(0xFFB8860B);

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

// ─── Tinted number field with an animated focus glow ───────────────────────
class _StyledNumberField extends StatefulWidget {
  final String label;
  final int value;
  final int? max;
  final ValueChanged<int> onChanged;

  const _StyledNumberField({
    required this.label,
    required this.value,
    this.max,
    required this.onChanged,
  });

  @override
  State<_StyledNumberField> createState() => _StyledNumberFieldState();
}

class _StyledNumberFieldState extends State<_StyledNumberField> with TickerProviderStateMixin {
  static const _gold = Color(0xFFB8860B);

  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  late final AnimationController _focusCtrl;
  // Animates the field's own displayed digits from the old to the new
  // value whenever it changes externally (e.g. auto-calc), so the person
  // sees the numbers climb instead of jumping instantly.
  late final AnimationController _countCtrl;
  double _countFrom = 0;
  double _countTo = 0;

  @override
  void initState() {
    super.initState();
    _countFrom = widget.value.toDouble();
    _countTo = widget.value.toDouble();
    _ctrl = TextEditingController(text: widget.value == 0 ? '' : widget.value.toString());
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _focusCtrl = AnimationController(vsync: this, duration: SetupDS.fast);
    _countCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
      ..addListener(_onCountTick);
  }

  void _onCountTick() {
    final t = Curves.easeOutCubic.transform(_countCtrl.value);
    final v = (_countFrom + (_countTo - _countFrom) * t).round();
    _ctrl.text = v == 0 ? '' : v.toString();
  }

  void _onFocusChange() {
    _focusNode.hasFocus ? _focusCtrl.forward() : _focusCtrl.reverse();
  }

  @override
  void didUpdateWidget(covariant _StyledNumberField old) {
    super.didUpdateWidget(old);
    if (widget.value == old.value) return;
    if (_focusNode.hasFocus) {
      // The person is actively typing here — sync silently, no animation.
      _countFrom = widget.value.toDouble();
      _countTo = widget.value.toDouble();
      return;
    }
    _countFrom = _countTo;
    _countTo = widget.value.toDouble();
    _countCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _focusCtrl.dispose();
    _countCtrl.dispose();
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
            final borderColor = Color.lerp(_gold.withValues(alpha: 0.65), _gold, t)!;
            return Container(
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                border: Border.all(color: borderColor, width: t > 0 ? 2.0 : 1.6),
                boxShadow: t > 0
                    ? [BoxShadow(color: _gold.withValues(alpha: 0.16), blurRadius: 10, offset: const Offset(0, 2))]
                    : null,
              ),
              child: child,
            );
          },
          child: Center(
            child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: primary),
              decoration: const InputDecoration(
                hintText: '0',
                filled: false,
                isDense: true,
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v) ?? 0;
                final clamped = widget.max != null ? parsed.clamp(0, widget.max!) : parsed.clamp(0, 999999);
                widget.onChanged(clamped);
              },
            ),
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

// ─── "Premium" stat card (total prayers) — light gray bg + green accent ───
class _PremiumStatCard extends StatelessWidget {
  final String label;
  final int value;
  final bool useArabic;

  const _PremiumStatCard({required this.label, required this.value, required this.useArabic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Container(
      padding: const EdgeInsets.all(SetupDS.cardPad),
      decoration: BoxDecoration(
        color: AppColors.mutedOf(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SetupDS.radiusLg),
        border: Border.all(color: AppColors.borderOf(context)),
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