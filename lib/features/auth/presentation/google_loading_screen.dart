import 'package:flutter/material.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../shared/widgets/mori_icon.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '_auth_bg.dart';

/// Design's `05 Google OAuth · loading`. Transitional interstitial: a
/// pulsing Mori icon above a tiny accent spinner, with "Memverifikasi
/// akun…" copy. Shown for deep-link or rehydration flows that need a
/// dedicated screen; in the standard path, SignInSelectScreen handles
/// its own inline loading state.
class GoogleLoadingScreen extends StatefulWidget {
  const GoogleLoadingScreen({super.key});

  @override
  State<GoogleLoadingScreen> createState() => _GoogleLoadingScreenState();
}

class _GoogleLoadingScreenState extends State<GoogleLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Scaffold(
      body: AuthGradientBg(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: Tween<double>(begin: 0.7, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _pulse,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const MoriIcon(size: 68, glow: true),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor:
                        MoriColors.accent.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      MoriColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Memverifikasi akun…',
                  style: context.text.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sebentar, Mori siapkan ruangmu.',
                  style: context.text.bodyMedium?.copyWith(
                    color: mori.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: MoriSpacing.s8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
