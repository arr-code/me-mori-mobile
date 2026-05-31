import 'package:flutter/material.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../shared/widgets/mori_icon.dart';
import '../../../shared/widgets/mori_wordmark.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_typography.dart';

/// Design's `Splash · D — Crest` (variant 4 in splash.jsx).
/// Brand-only boot loader — no CTAs. Concentric teal rings behind a
/// large brand mark, an orbiting accent dot, wordmark, and a small mono
/// caption at the foot. Shown during AuthUnknown; once auth resolves
/// the router pushes the user on.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbit;
  late final AnimationController _intro;
  late final Animation<double> _iconFade;
  late final Animation<Offset> _iconSlide;
  late final Animation<double> _wordFade;
  late final Animation<Offset> _wordSlide;

  static const _introCurve = Cubic(0.22, 0.61, 0.36, 1);

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();

    final iconInterval = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.74, curve: _introCurve),
    );
    _iconFade = Tween<double>(begin: 0, end: 1).animate(iconInterval);
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(iconInterval);

    final wordInterval = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.16, 1.0, curve: _introCurve),
    );
    _wordFade = Tween<double>(begin: 0, end: 1).animate(wordInterval);
    _wordSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(wordInterval);
  }

  @override
  void dispose() {
    _orbit.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MoriColors.darkBg : MoriColors.lightBg;
    final mori = context.mori;

    return Scaffold(
      backgroundColor: bg,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FractionalTranslation(
              translation: const Offset(0, -0.04),
              child: SizedBox(
                width: 420,
                height: 420,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _ConcentricRing(size: 420, alpha: isDark ? 0.10 : 0.14),
                    _ConcentricRing(size: 340, alpha: isDark ? 0.16 : 0.21),
                    _ConcentricRing(size: 260, alpha: isDark ? 0.22 : 0.28),
                    _OrbitingDot(orbit: _orbit, diameter: 340),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _iconFade,
                  child: SlideTransition(
                    position: _iconSlide,
                    child: const MoriIcon(size: 140, glow: true),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _wordFade,
                  child: SlideTransition(
                    position: _wordSlide,
                    child: const MoriWordmark(size: 34),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  'MEMENTO · MORI · MOMENTUM',
                  style: MoriTypography.mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: mori.dim,
                  ).copyWith(letterSpacing: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConcentricRing extends StatelessWidget {
  final double size;
  final double alpha;
  const _ConcentricRing({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: MoriColors.accent.withValues(alpha: alpha),
          ),
        ),
      ),
    );
  }
}

class _OrbitingDot extends StatelessWidget {
  final AnimationController orbit;
  final double diameter;
  const _OrbitingDot({required this.orbit, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: AnimatedBuilder(
          animation: orbit,
          builder: (_, __) {
            return Transform.rotate(
              angle: orbit.value * 2 * 3.1415926535,
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MoriColors.accent,
                      boxShadow: [
                        BoxShadow(
                          color: MoriColors.accent,
                          blurRadius: 14,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
