import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../design/design_tokens.dart';

/// Selectable option tile (approx pickers).
class SelectTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  const SelectTile({
    super.key,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SetupDS.fast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(SetupDS.radiusMd),
          border: Border.all(
            color: isSelected
                ? primary.withValues(alpha: 0.45)
                : AppColors.borderOf(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primary : null)),
                  Text(sublabel,
                      style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: SetupDS.fast,
              child: isSelected
                  ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey('checked'), color: primary, size: 20)
                  : Icon(Icons.radio_button_unchecked,
                      key: const ValueKey('empty'), color: mutedFg, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
