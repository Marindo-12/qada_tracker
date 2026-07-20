import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../design/design_tokens.dart';

/// Compact highlighted stat card.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final fg = accent ? primary : AppColors.foregroundOf(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent ? primary.withValues(alpha: 0.07) : muted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(SetupDS.radiusMd),
      ),
      child: Column(
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: AppColors.mutedFgOf(context)),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: fg, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Inline info strip (single-line info with icon).
class InfoStrip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;

  const InfoStrip(
      {super.key, required this.icon, required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SetupDS.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child:
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: primary)),
          ),
        ],
      ),
    );
  }
}

/// Approx toggle pill (header action).
class ApproxToggle extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const ApproxToggle({super.key, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SetupDS.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? primary.withValues(alpha: 0.12)
              : AppColors.mutedOf(context).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.help : Icons.help_outline,
              size: 13,
              color: active ? primary : mutedFg,
            ),
            const SizedBox(width: 4),
            Text(
              'لا أتذكر بالضبط؟',
              style: theme.textTheme.labelSmall?.copyWith(
                color: active ? primary : mutedFg,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Field section label.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style:
            Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700));
  }
}

/// Suggestion chip.
class SetupChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SetupChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: primary.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(20),
          color: primary.withValues(alpha: 0.05),
        ),
        child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: primary)),
      ),
    );
  }
}

/// Segmented mode tab (e.g. "granular" vs "days").
class ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final Color primary, mutedFg, surface;
  final VoidCallback onTap;

  const ModeTab({
    super.key,
    required this.label,
    required this.active,
    required this.primary,
    required this.mutedFg,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SetupDS.fast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(color: active ? primary : mutedFg),
          ),
        ),
      ),
    );
  }
}
