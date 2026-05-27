import 'package:flutter/material.dart';

class MoriColors {
  const MoriColors._();

  // Brand (constant across themes)
  static const accent = Color(0xFF14B8A6);
  static const accentSo = Color(0xFF0D8276);
  static const accentDk = Color(0xFF0B5C54);
  static const accentFg = Color(0xFF04211D);

  // Dark theme
  static const darkBg = Color(0xFF0F0E17);
  static const darkPanel = Color(0xFF1A1925);
  static const darkPanel2 = Color(0xFF232132);
  static const darkPanel3 = Color(0xFF2A2839);
  static const darkText = Color(0xFFFFFFFE);
  static const darkMuted = Color(0xFFA7A9BE);
  static const darkDim = Color(0xFF6E6F86);
  static const darkBorder = Color(0xFF2E2C3F);
  static const darkBorderSo = Color(0xFF222032);

  // Light theme
  static const lightBg = Color(0xFFF7F5F0);
  static const lightPanel = Color(0xFFFFFFFF);
  static const lightPanel2 = Color(0xFFF0ECE3);
  static const lightPanel3 = Color(0xFFE5E0D5);
  static const lightText = Color(0xFF18171F);
  static const lightMuted = Color(0xFF5E5C70);
  static const lightDim = Color(0xFF918F9F);
  static const lightBorder = Color(0xFFE0DBD0);
  static const lightBorderSo = Color(0xFFECE7DC);

  // Semantic (theme-aware tokens, picked in MoriTheme)
  static const warnDark = Color(0xFFFF8906);
  static const warnLight = Color(0xFFD66B00);
  static const okDark = Color(0xFF2CB67D);
  static const okLight = Color(0xFF1D8B5A);
  static const errDark = Color(0xFFE53170);
  static const errLight = Color(0xFFC12060);
}

class MoriTagPalette {
  final Color bg;
  final Color fg;
  const MoriTagPalette(this.bg, this.fg);
}

class MoriTagColors {
  const MoriTagColors._();

  static const kerja = MoriTagPalette(Color(0x2114B8A6), Color(0xFF5EEAD4));
  static const klien = MoriTagPalette(Color(0x21FF8906), Color(0xFFFFB661));
  static const fokus = MoriTagPalette(Color(0x298C5AFF), Color(0xFFB79DFF));
  static const pribadi = MoriTagPalette(Color(0x212CB67D), Color(0xFF7FE0B0));
  static const rutin = MoriTagPalette(Color(0x21A7A9BE), Color(0xFFC3C5D6));

  static MoriTagPalette forCategory(String category) {
    switch (category.toLowerCase()) {
      case 'kerja':
        return kerja;
      case 'klien':
        return klien;
      case 'fokus':
        return fokus;
      case 'pribadi':
        return pribadi;
      case 'rutin':
      default:
        return rutin;
    }
  }
}
