import 'package:flutter/material.dart';

import '../../theme/mori_colors.dart';

/// Brand icon. Renders [assets/icon/icon.png] with the design's rounded
/// squircle radius (size * 0.235) and an optional teal-tinted drop shadow.
class MoriIcon extends StatelessWidget {
  final double size;
  final double? radius;
  final bool glow;

  const MoriIcon({
    super.key,
    this.size = 64,
    this.radius,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.235;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Image.asset(
        'assets/icon/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );

    if (!glow) return image;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: MoriColors.accent.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: image,
    );
  }
}
