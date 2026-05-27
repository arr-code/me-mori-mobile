import 'package:flutter/material.dart';

import '../../theme/mori_colors.dart';
import '../../theme/mori_spacing.dart';
import '../../theme/mori_typography.dart';

class MTag extends StatelessWidget {
  final String label;
  final MoriTagPalette? palette;
  final String? category;

  const MTag({
    super.key,
    required this.label,
    this.palette,
  }) : category = null;

  MTag.category({
    super.key,
    required this.category,
    String? label,
  })  : label = label ?? (category ?? ''),
        palette = MoriTagColors.forCategory(category ?? '');

  @override
  Widget build(BuildContext context) {
    final p = palette ?? MoriTagColors.rutin;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MoriSpacing.s2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(MoriRadius.sm),
      ),
      child: Text(
        label.toUpperCase(),
        style: MoriTypography.mono(
          size: 11,
          weight: FontWeight.w500,
          color: p.fg,
        ).copyWith(letterSpacing: 0.3),
      ),
    );
  }
}
