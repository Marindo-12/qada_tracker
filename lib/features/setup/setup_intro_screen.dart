import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Design System Colors ─────────────────────────────────────────────────────
class AppColors {
  static const bg        = Color(0xFFF5F0E8);
  static const fg        = Color(0xFF1A2332);
  static const card      = Color(0xFFFFFFFF);
  static const border    = Color(0xFFD9CCB5);
  static const primary   = Color(0xFF0D6B45);
  static const primaryFg = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFE8DFC8);
  static const muted     = Color(0xFFE8DFC8);
  static const mutedFg   = Color(0xFF5A6A7A);
  static const accent    = Color(0xFFB8932A);
}

// ─── Screen ────────────────────────────────────────────────────────────────────
class SetupIntroScreen extends StatefulWidget {
  const SetupIntroScreen({super.key});

  @override
  State<SetupIntroScreen> createState() => _SetupIntroScreenState();
}

class _SetupIntroScreenState extends State<SetupIntroScreen>
    with TickerProviderStateMixin {

  // ── Word data ────────────────────────────────────────────────────────────────
  // Only "قضاء" animated — no الصلوات in the center stage
  static const String _baseWord = 'قضاء';
  static const String _fullWord = 'قَضَاءُ';

  // ── Per-letter controllers ────────────────────────────────────────────────
  late final List<AnimationController> _letterCtls;
  late final List<Animation<double>>   _letterFades;
  late final List<Animation<Offset>>   _letterSlides;

  // ── Phase controllers ──────────────────────────────────────────────────────
  late final AnimationController _glowCtl;       // accent color pulse
  late final AnimationController _swapCtl;       // swap to full word
  late final AnimationController _scaleCtl;      // scale up
  late final AnimationController _sweepCtl;      // white light sweep
  late final AnimationController _ornCtl;        // ornament line
  late final AnimationController _migrateCtl;    // word moves to header
  late final AnimationController _headerCtl;     // header word fades in
  late final AnimationController _stageCtl;      // stage height collapse
  late final AnimationController _r1Ctl, _r2Ctl, _r3Ctl, _r4Ctl; // content reveals

  // ── State ─────────────────────────────────────────────────────────────────
  bool _showFullWord   = false;
  bool _sweepRunning   = false;
  bool _stageCollapsed = false;

  @override
  void initState() {
    super.initState();
    _buildLetterControllers();
    _buildPhaseControllers();
    _runSequence();
  }

  void _buildLetterControllers() {
    final chars = _baseWord.characters.toList();
    _letterCtls = List.generate(
      chars.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 480)),
    );
    _letterFades = _letterCtls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _letterSlides = _letterCtls.map((c) =>
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.elasticOut)))
        .toList();
  }

  AnimationController _ctl(int ms) =>
      AnimationController(vsync: this, duration: Duration(milliseconds: ms));

  void _buildPhaseControllers() {
    _glowCtl    = _ctl(280);
    _swapCtl    = _ctl(350);
    _scaleCtl   = _ctl(700);
    _sweepCtl   = _ctl(1100);
    _ornCtl     = _ctl(500);
    _migrateCtl = _ctl(450);
    _headerCtl  = _ctl(450);
    _stageCtl   = _ctl(480);
    _r1Ctl      = _ctl(650);
    _r2Ctl      = _ctl(650);
    _r3Ctl      = _ctl(650);
    _r4Ctl      = _ctl(650);
  }

  // ── Main sequence ──────────────────────────────────────────────────────────
  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 1. Letters appear one by one
    for (int i = 0; i < _letterCtls.length; i++) {
      if (!mounted) return;
      _letterCtls[i].forward();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await Future.delayed(const Duration(milliseconds: 320));

    // 2. Accent glow flash
    if (!mounted) return;
    _glowCtl.forward();
    await Future.delayed(const Duration(milliseconds: 260));
    _glowCtl.reverse();
    await Future.delayed(const Duration(milliseconds: 200));

    // 2b. Swap to full word (tashkeel)
    if (!mounted) return;
    setState(() => _showFullWord = true);
    _swapCtl.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    // 3. Scale up
    if (!mounted) return;
    _scaleCtl.forward();
    await Future.delayed(const Duration(milliseconds: 260));

    // 3b. White sweep (right → left, RTL)
    if (!mounted) return;
    setState(() => _sweepRunning = true);
    _sweepCtl.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Ornament
    if (!mounted) return;
    _ornCtl.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // 4. Word migrates to header
    if (!mounted) return;
    _migrateCtl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _headerCtl.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Collapse stage
    if (!mounted) return;
    _stageCtl.forward();
    _stageCtl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _stageCollapsed = true);
      }
    });
    await Future.delayed(const Duration(milliseconds: 380));

    // 5. Content cascade
    for (final ctl in [_r1Ctl, _r2Ctl, _r3Ctl, _r4Ctl]) {
      if (!mounted) return;
      ctl.forward();
      await Future.delayed(const Duration(milliseconds: 240));
    }
  }

  @override
  void dispose() {
    for (final c in _letterCtls) {
      c.dispose();
    }
    for (final c in [
      _glowCtl, _swapCtl, _scaleCtl, _sweepCtl, _ornCtl,
      _migrateCtl, _headerCtl, _stageCtl,
      _r1Ctl, _r2Ctl, _r3Ctl, _r4Ctl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Subtle grid pattern
          const Positioned.fill(child: _GridPattern()),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeader(),

                // ── Animation stage ──────────────────────────────────────
                if (!_stageCollapsed) _buildStage(),

                // ── Ornament ─────────────────────────────────────────────
                if (!_stageCollapsed) _buildOrnament(),

                // ── Scrollable content ────────────────────────────────────
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
                    children: [
                      if (_stageCollapsed) _buildOrnament(),
                      _buildReveal(_r1Ctl, _buildWelcome()),
                      const SizedBox(height: 18),
                      _buildReveal(_r2Ctl, _buildCitationCard()),
                      const SizedBox(height: 18),
                      _buildReveal(_r3Ctl, _buildFeatures()),
                      const SizedBox(height: 24),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: _headerCtl,
            builder: (context, _) {
              final t = CurvedAnimation(
                parent: _headerCtl,
                curve: Curves.easeOutCubic,
              ).value;
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset((1 - t) * 20, 0),
                  child: Transform.scale(
                    scale: 0.85 + t * 0.15,
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'قَضَاءُ الصَّلَوَاتِ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Animation stage ────────────────────────────────────────────────────────
  Widget _buildStage() {
    return AnimatedBuilder(
      animation: _stageCtl,
      builder: (context, child) {
        final collapse = CurvedAnimation(parent: _stageCtl, curve: Curves.easeInOut).value;
        return SizedBox(
          height: (1 - collapse) * 200,
          child: Opacity(opacity: (1 - collapse), child: child),
        );
      },
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleCtl, _glowCtl, _sweepCtl, _swapCtl, _migrateCtl]),
            builder: (context, _) {
              final scale = Tween<double>(begin: 1.0, end: 1.18)
                  .animate(CurvedAnimation(parent: _scaleCtl, curve: Curves.elasticOut))
                  .value;
              final migrate = CurvedAnimation(parent: _migrateCtl, curve: Curves.easeInCubic).value;
              final glowT   = CurvedAnimation(parent: _glowCtl,  curve: Curves.easeOut).value;

              return Opacity(
                opacity: (1 - migrate),
                child: Transform.translate(
                  offset: Offset(20 * migrate, -30 * migrate),
                  child: Transform.scale(
                    scale: scale * (1 - migrate * 0.4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Word
                        _showFullWord
                            ? _buildFullWord(glowT)
                            : _buildLetterByLetter(glowT),

                        // White sweep
                        if (_sweepRunning) _buildSweep(),
                      ],
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

  Widget _buildLetterByLetter(double glowT) {
    final chars = _baseWord.characters.toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(chars.length, (i) {
          return SlideTransition(
            position: _letterSlides[i],
            child: FadeTransition(
              opacity: _letterFades[i],
              child: Text(
                chars[i],
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 88,
                  fontWeight: FontWeight.w700,
                  color: Color.lerp(AppColors.primary, AppColors.accent, glowT),
                  height: 1.0,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFullWord(double glowT) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _swapCtl, curve: Curves.easeIn),
      child: Text(
        _fullWord,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'ScheherazadeNew',
          fontSize: 88,
          fontWeight: FontWeight.w700,
          color: Color.lerp(AppColors.primary, AppColors.accent, glowT),
          height: 1.0,
        ),
      ),
    );
  }

  // White light sweep (RTL: right → left)
  Widget _buildSweep() {
    return AnimatedBuilder(
      animation: _sweepCtl,
      builder: (context, _) {
        final t = CurvedAnimation(parent: _sweepCtl, curve: Curves.easeInOut).value;
        // Goes from right (+1) to left (-0.2)
        final offsetX = (1 - t) * 1.0 - 0.2;
        return Positioned.fill(
          child: FractionalTranslation(
            translation: Offset(offsetX, 0),
            child: Transform(
              transform: Matrix4.skewX(-0.2),
              child: Container(
                width: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0x00FFFFFF),
                      Color(0xEEFFFFFF),
                      Color(0x00FFFFFF),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Ornament ───────────────────────────────────────────────────────────────
  Widget _buildOrnament() {
    return AnimatedBuilder(
      animation: _ornCtl,
      builder: (context, _) {
        final t = CurvedAnimation(parent: _ornCtl, curve: Curves.elasticOut).value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scaleX: t.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _line(false),
                  const SizedBox(width: 8),
                  _diamond(4, 0.5),
                  const SizedBox(width: 6),
                  _diamond(7, 1.0),
                  const SizedBox(width: 6),
                  _diamond(4, 0.5),
                  const SizedBox(width: 8),
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
    width: 56, height: 1,
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
        width: size, height: size,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    ),
  );

  // ── Welcome ────────────────────────────────────────────────────────────────
  Widget _buildWelcome() {
    return const Column(
      children: [
        Text(
          'أهلاً بك في قضاء الصلوات',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.fg,
            height: 1.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'رفيق هادئ يساعدك على قضاء صلواتك الفائتة\nبخطة يومية واضحة ومتابعة مستمرة.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 15,
            color: AppColors.mutedFg,
            height: 1.8,
          ),
        ),
      ],
    );
  }

  // ── Citation card ──────────────────────────────────────────────────────────
  Widget _buildCitationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Right accent bar
          Positioned(
            right: 0, top: 0, bottom: 0,
            child: Container(
              width: 3,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
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
                const Text(
                  'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 2.1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                const Text(
                  'سورة النساء — الآية ١٠٣',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: AppColors.mutedFg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Features ───────────────────────────────────────────────────────────────
  Widget _buildFeatures() {
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.fg,
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
  Widget _buildCTA() {
    return _ShimmerButton(
      label: 'إنشاء خطة القضاء',
      onPressed: () {
        // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetupScreen()));
      },
    );
  }

  Widget _buildHint() {
    return const Text(
      'يمكنك تعديل الخطة لاحقاً من الإعدادات.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 12,
        color: AppColors.mutedFg,
      ),
    );
  }

  // ── Generic reveal ─────────────────────────────────────────────────────────
  Widget _buildReveal(AnimationController ctl, Widget child) {
    return AnimatedBuilder(
      animation: ctl,
      builder: (context, _) {
        final t = CurvedAnimation(parent: ctl, curve: Curves.easeOutCubic).value;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 22), child: child),
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) { setState(() => _pressed = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, _) {
            final pos = _ctl.value;
            return Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                  colors: const [
                    AppColors.primary,
                    Color(0xFF0F8055),
                    AppColors.primary,
                  ],
                  stops: [
                    (pos - 0.35).clamp(0.0, 1.0),
                    pos.clamp(0.0, 1.0),
                    (pos + 0.35).clamp(0.0, 1.0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
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
  const _GridPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.025)
      ..strokeWidth = 0.8;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
