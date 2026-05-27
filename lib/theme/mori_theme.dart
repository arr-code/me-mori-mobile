import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mori_colors.dart';
import 'mori_spacing.dart';
import 'mori_typography.dart';

class MoriTheme {
  const MoriTheme._();

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: MoriColors.darkBg,
        surface: MoriColors.darkPanel,
        surface2: MoriColors.darkPanel2,
        surface3: MoriColors.darkPanel3,
        text: MoriColors.darkText,
        muted: MoriColors.darkMuted,
        dim: MoriColors.darkDim,
        border: MoriColors.darkBorder,
        borderSo: MoriColors.darkBorderSo,
        err: MoriColors.errDark,
        warn: MoriColors.warnDark,
        ok: MoriColors.okDark,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: MoriColors.lightBg,
        surface: MoriColors.lightPanel,
        surface2: MoriColors.lightPanel2,
        surface3: MoriColors.lightPanel3,
        text: MoriColors.lightText,
        muted: MoriColors.lightMuted,
        dim: MoriColors.lightDim,
        border: MoriColors.lightBorder,
        borderSo: MoriColors.lightBorderSo,
        err: MoriColors.errLight,
        warn: MoriColors.warnLight,
        ok: MoriColors.okLight,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surface2,
    required Color surface3,
    required Color text,
    required Color muted,
    required Color dim,
    required Color border,
    required Color borderSo,
    required Color err,
    required Color warn,
    required Color ok,
  }) {
    final cs = ColorScheme(
      brightness: brightness,
      primary: MoriColors.accent,
      onPrimary: MoriColors.accentFg,
      secondary: MoriColors.accentSo,
      onSecondary: MoriColors.accentFg,
      error: err,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surface2,
      outline: border,
      outlineVariant: borderSo,
    );

    final textTheme = MoriTypography.build(text, muted);

    final isDark = brightness == Brightness.dark;
    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: bg,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: text, size: 22),
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: systemOverlay,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MoriRadius.lg),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MoriSpacing.s4,
          vertical: MoriSpacing.s3,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: dim),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: err),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MoriRadius.md),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MoriRadius.md),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MoriRadius.md),
          borderSide: const BorderSide(color: MoriColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MoriRadius.md),
          borderSide: BorderSide(color: err, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MoriRadius.md),
          borderSide: BorderSide(color: err, width: 1.5),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MoriColors.accent,
          foregroundColor: MoriColors.accentFg,
          disabledBackgroundColor: surface2,
          disabledForegroundColor: dim,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MoriRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          backgroundColor: surface,
          side: BorderSide(color: border, width: 1),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MoriRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MoriColors.accent,
          textStyle: textTheme.labelLarge,
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: muted,
          selectedBackgroundColor: MoriColors.accent.withValues(alpha: 0.16),
          selectedForegroundColor: MoriColors.accent,
          side: BorderSide(color: border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MoriRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MoriRadius.md),
        ),
      ),

      extensions: [
        MoriColorsExtension(
          panel2: surface2,
          panel3: surface3,
          muted: muted,
          dim: dim,
          border: border,
          borderSo: borderSo,
          warn: warn,
          ok: ok,
          systemOverlay: systemOverlay,
        ),
      ],
    );
  }
}

@immutable
class MoriColorsExtension extends ThemeExtension<MoriColorsExtension> {
  final Color panel2;
  final Color panel3;
  final Color muted;
  final Color dim;
  final Color border;
  final Color borderSo;
  final Color warn;
  final Color ok;
  final SystemUiOverlayStyle systemOverlay;

  const MoriColorsExtension({
    required this.panel2,
    required this.panel3,
    required this.muted,
    required this.dim,
    required this.border,
    required this.borderSo,
    required this.warn,
    required this.ok,
    required this.systemOverlay,
  });

  @override
  MoriColorsExtension copyWith({
    Color? panel2,
    Color? panel3,
    Color? muted,
    Color? dim,
    Color? border,
    Color? borderSo,
    Color? warn,
    Color? ok,
    SystemUiOverlayStyle? systemOverlay,
  }) {
    return MoriColorsExtension(
      panel2: panel2 ?? this.panel2,
      panel3: panel3 ?? this.panel3,
      muted: muted ?? this.muted,
      dim: dim ?? this.dim,
      border: border ?? this.border,
      borderSo: borderSo ?? this.borderSo,
      warn: warn ?? this.warn,
      ok: ok ?? this.ok,
      systemOverlay: systemOverlay ?? this.systemOverlay,
    );
  }

  @override
  MoriColorsExtension lerp(ThemeExtension<MoriColorsExtension>? other, double t) {
    if (other is! MoriColorsExtension) return this;
    return MoriColorsExtension(
      panel2: Color.lerp(panel2, other.panel2, t)!,
      panel3: Color.lerp(panel3, other.panel3, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      dim: Color.lerp(dim, other.dim, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSo: Color.lerp(borderSo, other.borderSo, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      systemOverlay: t < 0.5 ? systemOverlay : other.systemOverlay,
    );
  }
}
