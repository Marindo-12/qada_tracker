import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Splash screen simple et moderne :
/// - un seul fade-in + léger scale du logo et du nom (pas d'animations en cascade)
/// - durée courte (~900ms au total) pour ne pas faire attendre l'utilisateur
/// - un fade-out propre vers le contenu de l'app
class AppStartSplashScreen extends StatefulWidget {
  final Widget child;

  const AppStartSplashScreen({
    super.key,
    required this.child,
  });

  @override
  State<AppStartSplashScreen> createState() => _AppStartSplashScreenState();
}

class _AppStartSplashScreenState extends State<AppStartSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<double> _fadeOut;

  bool _showChild = false;

  @override
  void initState() {
    super.initState();

    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 0% → 40% : apparition douce du logo + nom (fade + scale léger)
    _fadeIn = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
    );
    _scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
      ),
    );

    // 78% → 100% : fade-out vers le contenu de l'app
    _fadeOut = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
    );

    unawaited(_run());
  }

  Future<void> _run() async {
    await _ctl.forward();
    if (!mounted) return;
    setState(() => _showChild = true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showChild) return widget.child;

    final isDark = AppColors.isDark(context);
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _ctl,
            builder: (context, child) {
              return Opacity(
                opacity: (_fadeIn.value * (1 - _fadeOut.value)).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _scaleIn.value,
                  child: child,
                ),
              );
            },
            child: const _LogoBadge(),
          ),
        ),
      ),
    );
  }
}

/// L'icône seule, avec juste les coins arrondis — pas de cadre,
/// pas de fond ni de padding visibles autour.
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Image.asset(
        'assets/icon/icon.png',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      ),
    );
  }
}