import 'package:flutter/widgets.dart';

/// Shared spacing, radius, and duration tokens used throughout the setup flow.
class SetupDS {
  SetupDS._();

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double cardPad = 18;

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve entrance = Curves.easeOutCubic;
  static const Curve press = Curves.easeOut;
}
