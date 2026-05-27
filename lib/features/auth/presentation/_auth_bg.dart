import 'package:flutter/material.dart';

import '../../../theme/mori_colors.dart';

/// Radial gradient background used by the entry surfaces (splash, sign-in
/// select, google loading). Dark mode warms a deep-blue glow above the
/// page; light mode warms a teal glow.
class AuthGradientBg extends StatelessWidget {
  final Widget child;

  const AuthGradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MoriColors.darkBg : MoriColors.lightBg;
    final topGlow = isDark
        ? const Color(0xFF1A2438)
        : MoriColors.accent.withValues(alpha: 0.14);
    final bottomGlow =
        isDark ? const Color(0xFF07060E) : const Color(0xFFE8E2D3);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        gradient: RadialGradient(
          center: const Alignment(0, -0.65),
          radius: 1.25,
          colors: [topGlow, bg, bottomGlow],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}
