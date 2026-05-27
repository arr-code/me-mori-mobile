import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoriTypography {
  const MoriTypography._();

  static TextTheme build(Color textColor, Color mutedColor) {
    final display = GoogleFonts.plusJakartaSans;
    final body = GoogleFonts.inter;

    return TextTheme(
      // Display 36 — splash / onboarding hero
      displayMedium: display(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.05,
        color: textColor,
      ),
      // Title 28 — screen headlines
      headlineMedium: display(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.1,
        color: textColor,
      ),
      // Heading 20
      titleLarge: display(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.2,
        color: textColor,
      ),
      // Heading 17 — section titles
      titleMedium: body(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: textColor,
      ),
      // Body 15 — default
      bodyLarge: body(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.45,
        color: textColor,
      ),
      // Body 14 — secondary
      bodyMedium: body(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.05,
        height: 1.5,
        color: textColor,
      ),
      // Caption 12
      bodySmall: body(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
        color: mutedColor,
      ),
      // Label / button 15
      labelLarge: body(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.2,
        color: textColor,
      ),
      // Tag / mono 11
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: mutedColor,
      ),
    );
  }

  // Reusable mono style for username fields and tag chips.
  static TextStyle mono({
    double size = 15,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: 0,
        color: color,
      );
}
