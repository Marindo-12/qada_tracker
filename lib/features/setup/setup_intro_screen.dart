// lib/features/setup/setup_intro_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/providers/providers.dart';
import 'setup_screan.dart';

class SetupIntroScreen extends ConsumerStatefulWidget {
  const SetupIntroScreen({super.key});

  @override
  ConsumerState<SetupIntroScreen> createState() => _SetupIntroScreenState();
}

class _SetupIntroScreenState extends ConsumerState<SetupIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final List<Animation<double>> _reveals;

  // 5 sections : welcome, citation, features, CTA, hint
  static const _sectionCount = 5;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _reveals = List.generate(_sectionCount, (i) {
      final start = i * 0.15;
      final end   = (start + 0.45).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _ctl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
    // Small delay then cascade-reveal all sections
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _ctl.forward();
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final userName = ref.watch(userNameProvider).valueOrNull;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle grid background
          Positioned.fill(
            child: _GridPattern(color: AppColors.primaryOf(context)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header : قضاء top-right ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'قَضَاء',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOf(context),
                      ),
                    ),
                  ),
                ),

                // ── Ornement sous le titre ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ornLine(false),
                      const SizedBox(width: 7),
                      _ornDiamond(4, 0.5),
                      const SizedBox(width: 5),
                      _ornDiamond(7, 1.0),
                      const SizedBox(width: 5),
                      _ornDiamond(4, 0.5),
                      const SizedBox(width: 7),
                      _ornLine(true),
                    ],
                  ),
                ),

                // ── Scrollable content ─────────────────────────────────
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                    children: [
                      _reveal(0, _buildWelcome(context, userName)),
                      const SizedBox(height: 20),
                      _reveal(1, _buildCitationCard(context)),
                      const SizedBox(height: 20),
                      _reveal(2, _buildFeatures(context)),
                      const SizedBox(height: 28),
                      _reveal(3, _buildCTA(context)),
                      const SizedBox(height: 10),
                      _reveal(4, _buildHint(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ornament helpers ───────────────────────────────────────────────────────
  static Widget _ornLine(bool reversed) => Container(
        width: 52,
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: reversed
                ? [AppColors.accent, Colors.transparent]
                : [Colors.transparent, AppColors.accent],
          ),
        ),
      );

  static Widget _ornDiamond(double size, double opacity) => Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: 3.14159 / 4,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      );

  // ── Reveal wrapper ─────────────────────────────────────────────────────────
  Widget _reveal(int index, Widget child) {
    return AnimatedBuilder(
      animation: _reveals[index],
      builder: (_, __) {
        final t = _reveals[index].value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 22),
            child: child,
          ),
        );
      },
    );
  }

  // ── Welcome ────────────────────────────────────────────────────────────────
  Widget _buildWelcome(BuildContext context, String? userName) {
    final primary = AppColors.primaryOf(context);
    final fg      = AppColors.foregroundOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      children: [
        // Greeting line
        RichText(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.6,
            ),
            children: [
              const TextSpan(text: 'مرحباً بك '),
              if (userName != null && userName.isNotEmpty)
                TextSpan(
                  text: userName,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    shadows: [
                      Shadow(
                        color: primary.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              const TextSpan(text: ' في قضاء'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'رفيق هادئ يساعدك على قضاء صلواتك الفائتة\nبخطة يومية واضحة ومتابعة مستمرة.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 15,
            color: mutedFg,
            height: 1.9,
          ),
        ),
      ],
    );
  }

  // ── Citation card — no right border ────────────────────────────────────────
  Widget _buildCitationCard(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final isDark  = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        children: [
          Text(
            'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primary,
              height: 2.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          const SizedBox(height: 12),
          Text(
            'سورة النساء — الآية ١٠٣',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13,
              color: AppColors.mutedFgOf(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Features ───────────────────────────────────────────────────────────────
  Widget _buildFeatures(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final isDark  = AppColors.isDark(context);

    const features = [
      (Icons.calendar_month_outlined, 'حدد الفترة'),
      (Icons.track_changes_outlined,  'اختر روتينك'),
      (Icons.insights_outlined,       'تابع الإنجاز'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: features.map((f) {
          final (icon, label) = f;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: primary, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foregroundOf(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── CTA ────────────────────────────────────────────────────────────────────
  Widget _buildCTA(BuildContext context) {
    return _ShimmerButton(
      label: 'إنشاء خطة القضاء',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SetupScreen()),
      ),
    );
  }

  Widget _buildHint(BuildContext context) {
    return Text(
      'يمكنك تعديل الخطة لاحقاً من الإعدادات.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 12,
        color: AppColors.mutedFgOf(context),
      ),
    );
  }
}

// ─── Shimmer CTA button ────────────────────────────────────────────────────────
class _ShimmerButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _ShimmerButton({required this.label, required this.onPressed});

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final isDark  = AppColors.isDark(context);
    final mid = isDark
        ? const Color(0xFFD1A943)
        : const Color(0xFF0F8055);

    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) { setState(() => _pressed = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (_, __) {
            final p = _ctl.value;
            return Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [primary, mid, primary],
                  stops: [
                    (p - 0.35).clamp(0.0, 1.0),
                    p.clamp(0.0, 1.0),
                    (p + 0.35).clamp(0.0, 1.0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                widget.label,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Subtle grid background ────────────────────────────────────────────────────
class _GridPattern extends StatelessWidget {
  final Color color;
  const _GridPattern({required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(color));
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.035)
      ..strokeWidth = 0.8;
    const s = 40.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}