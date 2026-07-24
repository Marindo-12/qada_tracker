import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../design/design_tokens.dart';
import '../shared/animated_count.dart';
import '../shared/auto_calc_banner.dart';

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

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

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
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Column(
                  children: [
                    const SizedBox(width: double.infinity),
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
                _EstimateHelpButton(primary: primary),
              ],
            ),
            start: 0.0,
            end: 0.35,
          ),

          if (autoCalc != null) ...[
            const SizedBox(height: 20),
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
            const _OrnateInputLabel(),
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

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Replace the _EstimateHelpButton class (and _HelpPoint / _ExampleBox
// below it) in step_estimate.dart with the versions below. Everything else
// in the file — StepEstimate, _StyledNumberField, the stat cards, etc. —
// stays exactly as it was.

class _EstimateHelpButton extends StatelessWidget {
  final Color primary;

  const _EstimateHelpButton({required this.primary});

  @override
  Widget build(BuildContext context) {
    // Button is a plain rounded circle; the label sits underneath as a
    // caption instead of inline, so the tap target stays a clean round
    // shape while still telling the user what it does.
    return Tooltip(
      message: 'شرح اختيار القيم',
      child: InkWell(
        onTap: () => _showEstimateHelp(context),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: primary, width: 1.4),
              ),
              child: Icon(Icons.description_outlined, color: primary, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              'شرح',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEstimateHelp(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final screenH = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          // Cap the sheet instead of letting it grow to whatever the
          // content needs — this is what was pushing it to fill the
          // whole screen.
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenH * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderOf(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Sticky header ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 10, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.description_outlined, color: primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'كيف تختار السنوات والأشهر والأيام؟',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.borderOf(context)),

                // ── Scrollable body (only this part scrolls) ─────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اختر المدة الأقرب للحقيقة، لا رقما عشوائيا. حدد الفترة التي يغلب على ظنك أنك لم تكن تصلي فيها بانتظام، وأدخلها هنا كتقريب.',
                          style: theme.textTheme.bodySmall?.copyWith(color: mutedFg, height: 1.6),
                        ),
                        const SizedBox(height: 12),
                        const _HelpPoint(
                          icon: Icons.search_rounded,
                          title: 'ابدأ من أقرب تاريخ واضح',
                          text:
                              'إن لم تعرف اليوم بالضبط، اختر الأقرب: بداية سنة دراسية، رمضان معين، عمل جديد، أو مرحلة تذكر أنها كانت بداية التغيير.',
                        ),
                        const _HelpPoint(
                          icon: Icons.timeline_rounded,
                          title: 'قسّم حياتك إلى مراحل',
                          text:
                              'احسب فقط الفترات التي كان فيها التفريط واضحا، حتى إن توقفت وعدت أكثر من مرة، ثم اجمعها.',
                        ),
                        const _HelpPoint(
                          icon: Icons.verified_rounded,
                          title: 'اطمئن مع التقدير القريب',
                          text:
                              'إذا ترددت بين رقمين اختر الأقرب لظنك، ويمكنك زيادة هامش بسيط للاحتياط.',
                          showDivider: false,
                        ),
                        const SizedBox(height: 4),
                        const _ExampleBox(
                          title: 'مثال 1',
                          text:
                              'بدأ الالتزام 2024، لكنه صلى أحيانا بين 2021 و2024. فترة عدم الانتظام تقريبا سنتان و3 أشهر → يكتب: 2 سنوات، 3 أشهر.',
                        ),
                        const SizedBox(height: 8),
                        const _ExampleBox(
                          title: 'مثال 2',
                          text:
                              'لا يتذكر تاريخا دقيقا إطلاقا، فيعتمد تقديرا عاما بناء على عمره وبداية بلوغه، فيكتب مثلا 5 سنوات فقط دون تفاصيل الأشهر والأيام.',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Sticky footer button ──────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    10 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                          side: BorderSide(color: primary, width: 1.6),
                        ),
                      ),
                      // Center explicitly — this is what fixes the text
                      // sitting low: ElevatedButton's default child
                      // alignment can drift when height is constrained
                      // via SizedBox instead of minimumSize.
                      child: Center(
                        child: Text(
                          'فهمت',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HelpPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final bool showDivider;

  const _HelpPoint({
    required this.icon,
    required this.title,
    required this.text,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: primary, size: 17),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      style: theme.textTheme.bodySmall?.copyWith(color: mutedFg, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: AppColors.borderOf(context).withValues(alpha: 0.6)),
          ],
        ],
      ),
    );
  }
}

class _ExampleBox extends StatelessWidget {
  final String title;
  final String text;

  const _ExampleBox({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mutedOf(context).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(SetupDS.radiusMd),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(text, style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
        ],
      ),
    );
  } 
}

class _OrnateInputLabel extends StatelessWidget {
  const _OrnateInputLabel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);

    return Row(
      children: [
        Expanded(child: _MosqueLine(color: primary)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'سنوات / أشهر / أيام',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: _MosqueLine(color: primary, reverse: true)),
      ],
    );
  }
}

class _MosqueLine extends StatelessWidget {
  final Color color;
  final bool reverse;

  const _MosqueLine({required this.color, this.reverse = false});

  @override
  Widget build(BuildContext context) {
    final line = Container(
      height: 2,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(2),
      ),
    );
    final corner = Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.55), width: 2),
          right: BorderSide(color: color.withValues(alpha: 0.55), width: 2),
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
      ),
    );

    return Row(
      children: reverse
          ? [Expanded(child: line), Transform.rotate(angle: 3.14159, child: corner)]
          : [corner, Expanded(child: line)],
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
  static const _accent = AppColors.tertiaryContainer;

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
    final curved = CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut);

    return Column(
      children: [
        Text(
          widget.label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            final borderColor = Color.lerp(_accent.withValues(alpha: 0.65), _accent, t)!;
            return Container(
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                border: Border.all(color: borderColor, width: t > 0 ? 2.0 : 1.6),
                boxShadow: t > 0
                    ? [BoxShadow(color: _accent.withValues(alpha: 0.16), blurRadius: 10, offset: const Offset(0, 2))]
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
