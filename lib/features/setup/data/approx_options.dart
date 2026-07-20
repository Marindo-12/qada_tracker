class ApproxOption {
  final String label;
  final String sublabel;
  final int Function(DateTime base) toDays;

  const ApproxOption({
    required this.label,
    required this.sublabel,
    required this.toDays,
  });
}

final List<ApproxOption> commitmentApproxOptions = [
  ApproxOption(
    label: 'منذ سنة تقريباً',
    sublabel: 'حوالي ١٢ شهراً',
    toDays: (b) => b.difference(DateTime(b.year - 1, b.month, b.day)).inDays,
  ),
  ApproxOption(
    label: 'منذ سنتين تقريباً',
    sublabel: 'حوالي ٢ سنوات',
    toDays: (b) => b.difference(DateTime(b.year - 2, b.month, b.day)).inDays,
  ),
  ApproxOption(
    label: 'منذ ٥ سنوات تقريباً',
    sublabel: 'حوالي ٥ سنوات',
    toDays: (b) => b.difference(DateTime(b.year - 5, b.month, b.day)).inDays,
  ),
  ApproxOption(
    label: 'منذ ١٠ سنوات تقريباً',
    sublabel: 'حوالي عقد كامل',
    toDays: (b) => b.difference(DateTime(b.year - 10, b.month, b.day)).inDays,
  ),
  ApproxOption(
    label: 'منذ مطلع شبابي',
    sublabel: 'سنوات طويلة',
    toDays: (b) => b.difference(DateTime(b.year - 15, b.month, b.day)).inDays,
  ),
];

/// Male puberty age presets (١٥ سنة هجرياً is the common fiqh default).
const List<int> malePubertyAges = [12, 13, 14, 15];

/// Female puberty age presets.
const List<int> femalePubertyAges = [9, 10, 11, 12];
