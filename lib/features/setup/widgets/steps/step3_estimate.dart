import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/islamic_content.dart';
import '../../design/design_tokens.dart';
import '../shared/animated_count.dart';
import '../shared/tip_tile.dart';

/// ─── Step 3: Estimate ─────────────────────────────────────────────────────
///
/// Saisie simple en années / mois / jours, avec cartes statistiques animées.
/// La bannière automatique est remplacée par un texte d'information.
class StepEstimate extends StatefulWidget {
  final DateTime? bulughDate, commitmentDate;
  final int years, months, days;
  final bool useArabic;
  final ValueChanged<int> onYearsChanged, onMonthsChanged, onDaysChanged;

  const StepEstimate({
    super.key,
    required this.bulughDate,
    required this.commitmentDate,
    required this.years,
    required this.months,
    required this.days,
    required this.useArabic,
    required this.onYearsChanged,
    required this.onMonthsChanged,
    required this.onDaysChanged,
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

class _StepEstimateState extends State<StepEstimate>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _watermarkCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _watermarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _watermarkCtrl.dispose();
    super.dispose();
  }

  Widget _reveal(Widget child,
      {required double start, required double end}) {
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
        _reveal(
          Column(
            children: [
              Text(
                'تقدير الصلوات الفائتة',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: primary),
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
        _reveal(
          _GoldHadithCard(watermarkCtrl: _watermarkCtrl),
          start: 0.05,
          end: 0.4,
        ),
        if (autoCalc != null) ...[
          const SizedBox(height: 12),
          _reveal(
            Text(
              'بناءً على التواريخ المدخلة، الفترة تقدر بـ $autoCalc يوم.',
              style: theme.textTheme.bodyMedium?.copyWith(color: mutedFg),
              textAlign: TextAlign.center,
            ),
            start: 0.1,
            end: 0.45,
          ),
        ],
        const SizedBox(height: 20),
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
          const TipTile(
              icon: Icons.auto_awesome_rounded,
              text: IslamicContent.approxOk),
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
          BoxShadow(
              color: primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4)),
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
              child: Icon(Icons.auto_stories_rounded,
                  size: 72, color: primary.withValues(alpha: 0.08)),
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

class _StyledNumberFieldState extends State<_StyledNumberField>
    with TickerProviderStateMixin {
  static const _gold = Color(0xFFB8860B);

  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  late final AnimationController _focusCtrl;
  late final AnimationController _countCtrl;
  double _countFrom = 0;
  double _countTo = 0;

  @override
  void initState() {
    super.initState();
    _countFrom = widget.value.toDouble();
    _countTo = widget.value.toDouble();
    _ctrl = TextEditingController(
        text: widget.value == 0 ? '' : widget.value.toString());
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _focusCtrl = AnimationController(vsync: this, duration: SetupDS.fast);
    _countCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
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
        Text(widget.label,
            style: theme.textTheme.labelMedium?.copyWith(color: mutedFg)),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            final borderColor =
                Color.lerp(_gold.withValues(alpha: 0.65), _gold, t)!;
            return Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                border: Border.all(
                    color: borderColor, width: t > 0 ? 2.0 : 1.6),
                boxShadow: t > 0
                    ? [
                        BoxShadow(
                            color: _gold.withValues(alpha: 0.16),
                            blurRadius: 10,
                            offset: const Offset(0, 2))
                      ]
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
            textAlignVertical: TextAlignVertical.center,
            style: (widget.large
                    ? theme.textTheme.displaySmall
                    : theme.textTheme.headlineSmall)
                ?.copyWith(fontWeight: FontWeight.bold, color: primary),
            decoration: const InputDecoration(
              hintText: '0',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              isCollapsed: false,
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v) ?? 0;
              final clamped = widget.max != null
                  ? parsed.clamp(0, widget.max!)
                  : parsed.clamp(0, 999999);
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

  const _PlainStatCard(
      {required this.label, required this.value, required this.useArabic});

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
          BoxShadow(
              color: primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: mutedFg, letterSpacing: 0.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          AnimatedCount(
            value: value,
            useArabic: useArabic,
            style: theme.textTheme.headlineMedium?.copyWith(
                color: primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─── "Premium" stat card (total prayers) ───────────────────────────────────
class _PremiumStatCard extends StatelessWidget {
  final String label;
  final int value;
  final bool useArabic;

  const _PremiumStatCard(
      {required this.label, required this.value, required this.useArabic});

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
              style: theme.textTheme.labelSmall?.copyWith(
                  color: mutedFg, letterSpacing: 0.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          AnimatedCount(
            value: value,
            useArabic: useArabic,
            style: theme.textTheme.headlineMedium?.copyWith(
                color: primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}