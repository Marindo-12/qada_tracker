// lib/features/setup/username_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/providers/providers.dart';
import 'setup_intro_screen.dart';

class UsernameSetupScreen extends ConsumerStatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  ConsumerState<UsernameSetupScreen> createState() =>
      _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen> {
  late final TextEditingController _controller;
  bool _canSubmit = false;
  bool _saving    = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_syncCanSubmit);
  }

  void _syncCanSubmit() {
    final next = _controller.text.trim().isNotEmpty;
    if (next != _canSubmit) setState(() => _canSubmit = next);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncCanSubmit)
      ..dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);

    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setString(userNamePrefsKey, name);
    ref.invalidate(userNameProvider);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SetupIntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = AppColors.isDark(context);
    final primary = AppColors.primaryOf(context);
    final theme   = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'قَضَاء',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Avatar image ───────────────────────────────────
                  Image.asset(
                    'assets/icon/username.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                  // ── Title ───────────────────────────────────────────
                  Text(
                    'ما اسمك؟',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'سيُعرض اسمك داخل التطبيق فقط.',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedFgOf(context),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Text field ──────────────────────────────────────
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _submit(),
                    style: theme.textTheme.titleMedium,
                    decoration: const InputDecoration(
                      hintText: 'اسم المستخدم',
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Privacy note ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.mutedFgOf(context),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'محفوظ على جهازك فقط، لن نتمكن من الوصول إليه.',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedFgOf(context),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Submit button ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canSubmit && !_saving ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(double.infinity, 52),
                        alignment: Alignment.center,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Text(
                                  'تأكيد',
                                  style: TextStyle(height: 1),
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}