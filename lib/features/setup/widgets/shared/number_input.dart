import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class SetupNumberInput extends StatefulWidget {
  final String label;
  final String? hint;
  final int value;
  final int? max;
  final ValueChanged<int> onChanged;

  const SetupNumberInput({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    this.max,
    required this.onChanged,
  });

  @override
  State<SetupNumberInput> createState() => _SetupNumberInputState();
}

class _SetupNumberInputState extends State<SetupNumberInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant SetupNumberInput old) {
    super.didUpdateWidget(old);
    final next = widget.value.toString();
    if (!_ctrl.selection.isValid && _ctrl.text != next) _ctrl.text = next;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);
    return Column(
      children: [
        Text(widget.label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
          ),
          onChanged: (v) {
            final parsed = int.tryParse(v) ?? 0;
            final clamped =
                widget.max != null ? parsed.clamp(0, widget.max!) : parsed.clamp(0, 999999);
            widget.onChanged(clamped);
          },
        ),
      ],
    );
  }
}
