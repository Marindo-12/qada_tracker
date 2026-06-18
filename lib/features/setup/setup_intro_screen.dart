import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'setup_screan.dart';

// ─── Design System Colors ─────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFF5F0E8);
  static const fg = Color(0xFF1A2332);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFD9CCB5);
  static const primary = Color(0xFF0D6B45);
  static const primaryFg = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFE8DFC8);
  static const muted = Color(0xFFE8DFC8);
  static const mutedFg = Color(0xFF5A6A7A);
  static const accent = Color(0xFFB8932A);

  static const darkBg = Color(0xFF0F1621);
  static const darkFg = Color(0xFFF5F0E8);
  static const darkCard = Color(0xFF1A2535);
  static const darkBorder = Color(0xFF2A3545);
  static const darkMuted = Color(0xFF263447);
  static const darkMutedFg = Color(0xFFC7BFAE);
  static const darkPrimary = Color(0xFFB8932A);
  static const darkGreen = Color(0xFF0D6B45);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color bgOf(BuildContext context) => isDark(context) ? darkBg : bg;
  static Color fgOf(BuildContext context) => isDark(context) ? darkFg : fg;
  static Color cardOf(BuildContext context) =>
      isDark(context) ? darkCard : card;
  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : border;
  static Color mutedOf(BuildContext context) =>
      isDark(context) ? darkMuted : muted;
  static Color mutedFgOf(BuildContext context) =>
      isDark(context) ? darkMutedFg : mutedFg;
  static Color primaryOf(BuildContext context) =>
      isDark(context) ? darkPrimary : primary;
  static Color greenOf(BuildContext context) =>
      isDark(context) ? darkGreen : primary;
}

class SetupIntroScreen extends StatefulWidget {
  const SetupIntroScreen({super.key});

  @override
  State<SetupIntroScreen> createState() => _SetupIntroScreenState();
}

class _SetupIntroScreenState extends State<SetupIntroScreen>
    with TickerProviderStateMixin {
  // قضاء individual letters (RTL order as displayed: ق ض ا ء)
  static const _letters = ['ق', 'ض', 'ا', 'ء'];
  static const _fullWord = 'قَضَاءُ';

  // ── Flash-letter animation (single letter shown/hidden) ────────────────────
  late final AnimationController _flashInCtl;
  late final AnimationController _flashOutCtl;

  // ── Full word build-up (char by char) ─────────────────────────────────────
  late final List<AnimationController> _charCtls;
  late final List<Animation<double>> _charFades;
  late final List<Animation<Offset>> _charSlides;

  // ── Phase controllers ──────────────────────────────────────────────────────
  late final AnimationController _glowCtl; // accent pulse on full word
  late final AnimationController _sweepCtl; // white light sweep
  late final AnimationController _ornCtl; // ornament line
  late final AnimationController _migrateCtl; // full word shrinks → header
  late final AnimationController _headerCtl; // header word slides in
  late final AnimationController _stageCtl; // stage height collapse
  late final AnimationController _r1Ctl, _r2Ctl, _r3Ctl, _r4Ctl;

  // ── Runtime state ─────────────────────────────────────────────────────────
  int _currentFlashIndex = -1; // which letter is currently shown (-1 = none)
  bool _showFullWord = false;
  bool _sweepRunning = false;
  bool _stageCollapsed = false;

  @override
  void initState() {
    super.initState();
    _buildControllers();
    _runSequence();
  }

  AnimationController _ctl(int ms) =>
      AnimationController(vsync: this, duration: Duration(milliseconds: ms));

  void _buildControllers() {
    // Flash in/out for single letter
    _flashInCtl = _ctl(220);
    _flashOutCtl = _ctl(180);

    // Per-char controllers for full word build-up
    final count = _fullWord.characters.length;
    _charCtls = List.generate(count, (_) => _ctl(300));
    _charFades = _charCtls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _charSlides = _charCtls
        .map((c) => Tween<Offset>(
                begin: const Offset(0, 0.35), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();

    _glowCtl = _ctl(280);
    _sweepCtl = _ctl(1000);
    _ornCtl = _ctl(480);
    _migrateCtl = _ctl(420);
    _headerCtl = _ctl(480);
    _stageCtl = _ctl(480);
    _r1Ctl = _ctl(650);
    _r2Ctl = _ctl(650);
    _r3Ctl = _ctl(650);
    _r4Ctl = _ctl(650);
  }

  // ── Main sequence ──────────────────────────────────────────────────────────
  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 350));

    // Phase 1 — flash each letter individually: show → hide → next
    for (int i = 0; i < _letters.length; i++) {
      if (!mounted) return;

      // Show letter
      _flashInCtl.reset();
      setState(() => _currentFlashIndex = i);
      _flashInCtl.forward();
      await Future.delayed(const Duration(milliseconds: 320));

      // Hide letter
      _flashOutCtl.reset();
      _flashOutCtl.forward();
      await Future.delayed(const Duration(milliseconds: 180));

      setState(() => _currentFlashIndex = -1);
      await Future.delayed(const Duration(milliseconds: 40));
    }

    await Future.delayed(const Duration(milliseconds: 60));

    // Phase 2 — build full word char by char
    if (!mounted) return;
    setState(() => _showFullWord = true);

    final chars = _fullWord.characters.toList();
    for (int i = 0; i < chars.length; i++) {
      if (!mounted) return;
      _charCtls[i].forward();
      await Future.delayed(const Duration(milliseconds: 90));
    }
    await Future.delayed(const Duration(milliseconds: 200));

    // Phase 3 — accent color flash
    if (!mounted) return;
    _glowCtl.forward();
    await Future.delayed(const Duration(milliseconds: 280));
    _glowCtl.reverse();
    await Future.delayed(const Duration(milliseconds: 120));

    // Phase 4 — white light sweep
    if (!mounted) return;
    setState(() => _sweepRunning = true);
    _sweepCtl.forward();
    await Future.delayed(const Duration(milliseconds: 380));

    // Phase 5 — ornament
    if (!mounted) return;
    _ornCtl.forward();
    await Future.delayed(const Duration(milliseconds: 520));

    // Phase 6 — migrate word to header
    if (!mounted) return;
    _migrateCtl.forward();
    await Future.delayed(const Duration(milliseconds: 160));
    _headerCtl.forward();
    await Future.delayed(const Duration(milliseconds: 280));

    // Phase 7 — collapse stage
    if (!mounted) return;
    _stageCtl.forward();
    _stageCtl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _stageCollapsed = true);
      }
    });
    await Future.delayed(const Duration(milliseconds: 380));

    // Phase 8 — content cascade
    for (final ctl in [_r1Ctl, _r2Ctl, _r3Ctl, _r4Ctl]) {
      if (!mounted) return;
      ctl.forward();
      await Future.delayed(const Duration(milliseconds: 230));
    }
  }

  @override
  void dispose() {
    _flashInCtl.dispose();
    _flashOutCtl.dispose();
    for (final c in _charCtls) {
      c.dispose();
    }
    for (final c in [
      _glowCtl,
      _sweepCtl,
      _ornCtl,
      _migrateCtl,
      _headerCtl,
      _stageCtl,
      _r1Ctl,
      _r2Ctl,
      _r3Ctl,
      _r4Ctl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: Stack(
        children: [
          Positioned.fill(
              child: _GridPattern(color: AppColors.primaryOf(context))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),

                // Stage takes all remaining space until collapsed
                if (!_stageCollapsed) _buildStageExpanded(),

                if (!_stageCollapsed) _buildOrnament(),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
                    children: [
                      if (_stageCollapsed) ...[
                        _buildOrnament(),
                        const SizedBox(height: 16),
                      ],
                      _buildReveal(_r1Ctl, _buildWelcome()),
                      const SizedBox(height: 16),
                      _buildReveal(_r2Ctl, _buildCitationCard()),
                      const SizedBox(height: 16),
                      _buildReveal(_r3Ctl, _buildFeatures()),
                      const SizedBox(height: 22),
                      _buildReveal(_r4Ctl, _buildCTA()),
                      const SizedBox(height: 10),
                      _buildReveal(_r4Ctl, _buildHint()),
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

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _headerCtl,
            builder: (context, _) {
              final t = CurvedAnimation(
                parent: _headerCtl,
                curve: Curves.easeOutCubic,
              ).value;
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset((1 - t) * -18, 0),
                  child: Transform.scale(
                    scale: 0.88 + t * 0.12,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'قَضَاء',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOf(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Stage: fills all remaining vertical space, content truly centered ───────
  Widget _buildStageExpanded() {
    return Expanded(
      child: AnimatedBuilder(
        animation: _stageCtl,
        builder: (context, child) {
          final collapse = CurvedAnimation(
            parent: _stageCtl,
            curve: Curves.easeInOut,
          ).value;
          return Opacity(
            opacity: (1 - collapse).clamp(0.0, 1.0),
            child: child,
          );
        },
        child: ClipRect(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _flashInCtl,
                _flashOutCtl,
                _glowCtl,
                _sweepCtl,
                _migrateCtl,
              ]),
              builder: (context, _) {
                final migrateT = CurvedAnimation(
                  parent: _migrateCtl,
                  curve: Curves.easeInCubic,
                ).value;
                final glowT = CurvedAnimation(
                  parent: _glowCtl,
                  curve: Curves.easeOut,
                ).value;

                return Opacity(
                  opacity: (1 - migrateT).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(migrateT * -90, migrateT * -28),
                    child: Transform.scale(
                      scale: 1.0 - migrateT * 0.45,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Flash single letter
                          if (!_showFullWord) _buildFlashLetter(),

                          // Full word build-up
                          if (_showFullWord) _buildFullWord(glowT),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Single letter flash ───────────────────────────────────────────────────
  Widget _buildFlashLetter() {
    if (_currentFlashIndex < 0) return const SizedBox.shrink();
    final letter = _letters[_currentFlashIndex];

    return AnimatedBuilder(
      animation: Listenable.merge([_flashInCtl, _flashOutCtl]),
      builder: (context, _) {
        // Flash IN: scale up from small + fade in
        final inT =
            CurvedAnimation(parent: _flashInCtl, curve: Curves.easeOutBack)
                .value;
        // Flash OUT: fade out + slight scale up
        final outT =
            CurvedAnimation(parent: _flashOutCtl, curve: Curves.easeIn).value;

        final opacity = _flashOutCtl.isAnimating
            ? (1.0 - outT).clamp(0.0, 1.0)
            : inT.clamp(0.0, 1.0);
        final scale =
            _flashOutCtl.isAnimating ? 1.0 + outT * 0.08 : 0.65 + inT * 0.35;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Text(
              letter,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 120,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOf(context),
                height: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Full word (char by char build-up) ────────────────────────────────────
  Widget _buildFullWord(double glowT) {
    final chars = _fullWord.characters.toList();
    final primary = AppColors.primaryOf(context);
    final baseColor = Color.lerp(primary, AppColors.accent, glowT) ?? primary;
    final word = Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(chars.length, (i) {
          if (i >= _charCtls.length) return const SizedBox.shrink();
          return SlideTransition(
            position: _charSlides[i],
            child: FadeTransition(
              opacity: _charFades[i],
              child: Text(
                chars[i],
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 88,
                  fontWeight: FontWeight.w700,
                  color: baseColor,
                  height: 1.0,
                ),
              ),
            ),
          );
        }),
      ),
    );

    if (!_sweepRunning) return word;

    final sweepT =
        CurvedAnimation(parent: _sweepCtl, curve: Curves.easeInOut).value;
    final center = (1.05 - sweepT * 1.25).clamp(0.0, 1.0);
    final left = (center - 0.18).clamp(0.0, 1.0);
    final right = (center + 0.18).clamp(0.0, 1.0);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            baseColor,
            Colors.white,
            baseColor,
          ],
          stops: [
            left,
            center,
            right,
          ],
        ).createShader(bounds);
      },
      child: word,
    );
  }

  // ── Ornament line ─────────────────────────────────────────────────────────
  Widget _buildOrnament() {
    return AnimatedBuilder(
      animation: _ornCtl,
      builder: (context, _) {
        final t = CurvedAnimation(parent: _ornCtl, curve: Curves.elasticOut)
            .value
            .clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scaleX: t,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _line(false),
                  const SizedBox(width: 7),
                  _diamond(4, 0.5),
                  const SizedBox(width: 5),
                  _diamond(7, 1.0),
                  const SizedBox(width: 5),
                  _diamond(4, 0.5),
                  const SizedBox(width: 7),
                  _line(true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _line(bool reversed) => Container(
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

  Widget _diamond(double size, double opacity) => Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: math.pi / 4,
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

  // ── Welcome ───────────────────────────────────────────────────────────────
  Widget _buildWelcome() {
    return Column(
      children: [
        Text(
          'أهلاً بك في قضاء ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.fgOf(context),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'رفيق هادئ يساعدك على قضاء صلواتك الفائتة\nبخطة يومية واضحة ومتابعة مستمرة.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 15,
            color: AppColors.mutedFgOf(context),
            height: 1.8,
          ),
        ),
      ],
    );
  }

  // ── Citation card ──────────────────────────────────────────────────────────
  Widget _buildCitationCard() {
    final primary = AppColors.primaryOf(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 22, 18),
            child: Column(
              children: [
                Text(
                  'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    height: 2.1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.borderOf(context)),
                const SizedBox(height: 10),
                Text(
                  'سورة النساء — الآية ١٠٣',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: AppColors.mutedFgOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Features ──────────────────────────────────────────────────────────────
  Widget _buildFeatures() {
    final primary = AppColors.primaryOf(context);
    const features = [
      (Icons.calendar_month_outlined, 'حدد الفترة'),
      (Icons.track_changes_outlined, 'اختر روتينك'),
      (Icons.insights_outlined, 'تابع الإنجاز'),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: features.map((f) {
          final (icon, label) = f;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.cardOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: primary, size: 20),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.fgOf(context),
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

  // ── CTA ───────────────────────────────────────────────────────────────────
  Widget _buildCTA() {
    return _ShimmerButton(
      label: 'إنشاء خطة القضاء',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SetupScreen()),
        );
      },
    );
  }

  Widget _buildHint() {
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

  // ── Generic reveal ─────────────────────────────────────────────────────────
  Widget _buildReveal(AnimationController ctl, Widget child) {
    return AnimatedBuilder(
      animation: ctl,
      builder: (context, _) {
        final t =
            CurvedAnimation(parent: ctl, curve: Curves.easeOutCubic).value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 20),
            child: child,
          ),
        );
      },
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
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, _) {
            final pos = _ctl.value;
            final primary = AppColors.primaryOf(context);
            final mid = AppColors.isDark(context)
                ? const Color(0xFFD1A943)
                : const Color(0xFF0F8055);
            return Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                  colors: [
                    primary,
                    mid,
                    primary,
                  ],
                  stops: [
                    (pos - 0.35).clamp(0.0, 1.0),
                    pos.clamp(0.0, 1.0),
                    (pos + 0.35).clamp(0.0, 1.0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'إنشاء خطة القضاء',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryFg,
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
