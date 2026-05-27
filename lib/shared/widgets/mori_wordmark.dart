import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extensions/context_theme.dart';

/// Two-toned "Me Mori" wordmark — "Me" lighter, "Mori" bold.
class MoriWordmark extends StatelessWidget {
  final double size;
  final Color? color;
  final String? sub;

  const MoriWordmark({
    super.key,
    this.size = 28,
    this.color,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.cs.onSurface;
    final base = GoogleFonts.plusJakartaSans(
      fontSize: size,
      color: c,
      height: 1,
      letterSpacing: -0.5,
    );

    return DefaultTextStyle.merge(
      style: base,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'Me',
            style: base.copyWith(
              fontWeight: FontWeight.w400,
              color: c.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: size * 0.18),
          Text(
            'Mori',
            style: base.copyWith(fontWeight: FontWeight.w700),
          ),
          if (sub != null) ...[
            SizedBox(width: size * 0.25),
            Text(
              sub!,
              style: base.copyWith(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w500,
                color: c.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
