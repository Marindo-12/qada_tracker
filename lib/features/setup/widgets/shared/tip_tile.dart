import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../design/design_tokens.dart';

/// Small muted tip row — secondary info, quiet design.
class TipTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const TipTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Theme.of(context).colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(SetupDS.radiusMd),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.foregroundOf(context).withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
