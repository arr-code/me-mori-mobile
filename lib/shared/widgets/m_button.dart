import 'package:flutter/material.dart';

import '../../theme/mori_colors.dart';
import '../../theme/mori_spacing.dart';
import '../../theme/mori_theme.dart';
import '../extensions/context_theme.dart';

enum MButtonVariant { primary, secondary, ghost, warn, danger, outline }

enum MButtonSize { md, lg }

class MButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final MButtonVariant variant;
  final MButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;

  const MButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MButtonVariant.primary,
    this.size = MButtonSize.lg,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final cs = context.cs;
    final text = context.text;

    final spec = _resolveSpec(variant, cs, mori);
    final height = size == MButtonSize.lg ? 56.0 : 48.0;
    final fontSize = size == MButtonSize.lg ? 16.0 : 15.0;
    final horizontalPadding =
        size == MButtonSize.lg ? MoriSpacing.s6 : MoriSpacing.s4;
    final isDisabled = onPressed == null || loading;

    final effectiveBg = isDisabled ? spec.disabledBg : spec.bg;
    final effectiveFg = isDisabled ? spec.disabledFg : spec.fg;

    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: effectiveFg),
                const SizedBox(width: MoriSpacing.s2),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: text.labelLarge?.copyWith(
                    color: effectiveFg,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: MoriSpacing.s2),
                Icon(trailingIcon, size: 18, color: effectiveFg),
              ],
            ],
          );

    final button = Material(
      color: effectiveBg,
      borderRadius: BorderRadius.circular(MoriRadius.md),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(MoriRadius.md),
        splashColor: spec.fg.withValues(alpha: 0.08),
        highlightColor: spec.fg.withValues(alpha: 0.04),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MoriRadius.md),
            border: spec.borderColor != null
                ? Border.all(color: spec.borderColor!, width: 1)
                : null,
          ),
          child: Container(
            alignment: Alignment.center,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          ),
        ),
      ),
    );

    // Primary gets a teal-tinted drop shadow per design.
    final wrapped = spec.shadow != null && !isDisabled
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MoriRadius.md),
              boxShadow: [spec.shadow!],
            ),
            child: button,
          )
        : button;

    return fullWidth ? SizedBox(width: double.infinity, child: wrapped) : wrapped;
  }

  _ButtonSpec _resolveSpec(
    MButtonVariant v,
    ColorScheme cs,
    MoriColorsExtension mori,
  ) {
    switch (v) {
      case MButtonVariant.primary:
        return _ButtonSpec(
          bg: MoriColors.accent,
          fg: MoriColors.accentFg,
          disabledBg: mori.panel2,
          disabledFg: mori.dim,
          shadow: BoxShadow(
            color: MoriColors.accent.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 6),
          ),
        );
      case MButtonVariant.secondary:
        return _ButtonSpec(
          bg: mori.panel2,
          fg: cs.onSurface,
          borderColor: mori.border,
          disabledBg: mori.panel2,
          disabledFg: mori.dim,
        );
      case MButtonVariant.ghost:
        return _ButtonSpec(
          bg: Colors.transparent,
          fg: mori.muted,
          disabledBg: Colors.transparent,
          disabledFg: mori.dim,
        );
      case MButtonVariant.outline:
        return _ButtonSpec(
          bg: Colors.transparent,
          fg: cs.onSurface,
          borderColor: mori.border,
          disabledBg: Colors.transparent,
          disabledFg: mori.dim,
        );
      case MButtonVariant.warn:
        // Tinted background + warn-coloured label + warn border.
        return _ButtonSpec(
          bg: mori.warn.withValues(alpha: 0.13),
          fg: mori.warn,
          borderColor: mori.warn.withValues(alpha: 0.4),
          disabledBg: mori.panel2,
          disabledFg: mori.dim,
        );
      case MButtonVariant.danger:
        return _ButtonSpec(
          bg: cs.error.withValues(alpha: 0.12),
          fg: cs.error,
          borderColor: cs.error.withValues(alpha: 0.35),
          disabledBg: mori.panel2,
          disabledFg: mori.dim,
        );
    }
  }
}

class _ButtonSpec {
  final Color bg;
  final Color fg;
  final Color disabledBg;
  final Color disabledFg;
  final Color? borderColor;
  final BoxShadow? shadow;

  _ButtonSpec({
    required this.bg,
    required this.fg,
    required this.disabledBg,
    required this.disabledFg,
    this.borderColor,
    this.shadow,
  });
}
