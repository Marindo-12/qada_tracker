import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/approx_options.dart';
import '../../data/islamic_content.dart';
import '../../design/design_tokens.dart';
import '../shared/date_field.dart';
import '../shared/hadith_card.dart';
import '../shared/misc_widgets.dart';
import '../shared/select_tile.dart';
import '../shared/tip_tile.dart';

class StepCommitment extends StatelessWidget {
  final DateTime? bulughDate, commitmentDate;
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
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);

    final diff = bulughDate != null && commitmentDate != null
        ? commitmentDate!.difference(bulughDate!).inDays
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: FieldLabel('تاريخ الالتزام بالصلاة')),
            ApproxToggle(active: commitmentApprox, onTap: () => onApproxChanged(!commitmentApprox)),
          ],
        ),
        const SizedBox(height: 12),
        const HadithCard(main: IslamicContent.commitmentHelp, sub: IslamicContent.commitmentSub),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: SetupDS.normal,
          child: commitmentApprox
              ? _CommitmentApproxPicker(
                  key: const ValueKey('approx'),
                  bulughDate: bulughDate,
                  selected: commitmentDate,
                  onSelected: onChanged,
                )
              : _CommitmentExactSection(
                  key: const ValueKey('exact'),
                  bulughDate: bulughDate,
                  commitmentDate: commitmentDate,
                  onChanged: onChanged,
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
      ],
    );
  }
}

class _CommitmentExactSection extends StatelessWidget {
  final DateTime? bulughDate, commitmentDate;
  final ValueChanged<DateTime?> onChanged;

  const _CommitmentExactSection({
    super.key,
    required this.bulughDate,
    required this.commitmentDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final now = DateTime.now();
    final chips = [
      ('منذ ٦ أشهر', DateTime(now.year, now.month - 6, now.day)),
      ('منذ سنة', DateTime(now.year - 1, now.month, now.day)),
      ('منذ ٣ سنوات', DateTime(now.year - 3, now.month, now.day)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SetupDateField(
          hint: 'التاريخ الذي بدأت بالمحافظة على الصلاة',
          value: commitmentDate,
          firstDate: bulughDate ?? DateTime(1900),
          lastDate: now,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Text('أو اختر تقريباً:', style: theme.textTheme.labelMedium?.copyWith(color: mutedFg)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((c) {
            final valid = bulughDate == null || c.$2.isAfter(bulughDate!);
            if (!valid) return const SizedBox.shrink();
            return SetupChip(label: c.$1, onTap: () => onChanged(c.$2));
          }).toList(),
        ),
      ],
    );
  }
}

class _CommitmentApproxPicker extends StatefulWidget {
  final DateTime? bulughDate, selected;
  final ValueChanged<DateTime?> onSelected;

  const _CommitmentApproxPicker({
    super.key,
    required this.bulughDate,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CommitmentApproxPicker> createState() => _CommitmentApproxPickerState();
}

class _CommitmentApproxPickerState extends State<_CommitmentApproxPicker> {
  bool _showPresets = true;
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
    final date = DateTime(year, 6, 1);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                active: _showPresets,
                primary: primary,
                mutedFg: mutedFg,
                surface: AppColors.surfaceOf(context),
                onTap: () => setState(() => _showPresets = true),
              ),
              ModeTab(
                label: 'سنة محددة',
                active: !_showPresets,
                primary: primary,
                mutedFg: mutedFg,
                surface: AppColors.surfaceOf(context),
                onTap: () => setState(() => _showPresets = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: SetupDS.normal,
          child: _showPresets
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
                  key: const ValueKey('yearInput'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أدخل السنة التي التزمت فيها بالصلاة',
                        style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
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
                            onChanged: _applyYear,
                            onSubmitted: _applyYear,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (widget.selected != null && !_showPresets)
                      InfoStrip(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'سيتم احتساب الالتزام منذ منتصف سنة ${widget.selected!.year}',
                        primary: primary,
                      ),
                    if (_yearCtrl.text.isNotEmpty &&
                        (int.tryParse(_yearCtrl.text) == null ||
                            (int.tryParse(_yearCtrl.text) ?? 0) < 1950 ||
                            (int.tryParse(_yearCtrl.text) ?? 9999) > now.year))
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
                            SetupChip(
                              label: '${now.year - offset}',
                              onTap: () {
                                _yearCtrl.text = '${now.year - offset}';
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
