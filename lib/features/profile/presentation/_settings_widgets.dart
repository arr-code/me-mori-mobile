import 'package:flutter/material.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../../../theme/mori_typography.dart';

/// Uppercase group title + rounded panel container that hosts a series of
/// `SettingsRow`s. Use a null/empty title for a standalone row (e.g.
/// the logout row at the bottom of the screen).
class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Text(
                title!.toUpperCase(),
                style: context.text.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: mori.muted,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.cs.surface,
                border: Border.all(color: mori.borderSo),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row inside a [SettingsGroup]. Label on top, optional value below,
/// optional [hint] under that, optional trailing [right] widget. When no
/// [right] is provided and [chevron] is true, a small chevron is drawn.
class SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final Widget? right;
  final bool chevron;
  final bool danger;
  final bool locked;
  final bool multiline;
  final bool monospaceValue;
  final bool isLast;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.right,
    this.chevron = true,
    this.danger = false,
    this.locked = false,
    this.multiline = false,
    this.monospaceValue = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final err = context.cs.error;

    final valueStyle = monospaceValue
        ? MoriTypography.mono(
            size: 14.5,
            weight: FontWeight.w500,
            color: danger ? err : context.cs.onSurface,
          )
        : context.text.bodyLarge?.copyWith(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: danger ? err : context.cs.onSurface,
            letterSpacing: -0.1,
            height: 1.4,
          );

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: context.text.bodySmall?.copyWith(
                          fontSize: 12,
                          color: mori.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (locked)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          '· terkunci',
                          style: context.text.bodySmall?.copyWith(
                            fontSize: 10,
                            color: mori.dim,
                          ),
                        ),
                      ),
                  ],
                ),
                if (value != null && value!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    value!,
                    style: valueStyle,
                    overflow: multiline
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    maxLines: multiline ? null : 1,
                  ),
                ],
                if (hint != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hint!,
                    style: context.text.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: mori.dim,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (right != null) ...[
            const SizedBox(width: MoriSpacing.s3),
            right!,
          ] else if (chevron) ...[
            const SizedBox(width: MoriSpacing.s3),
            Icon(Icons.chevron_right_rounded, size: 18, color: mori.dim),
          ],
        ],
      ),
    );

    final bordered = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: mori.borderSo),
        ),
      ),
      child: row,
    );

    if (onTap == null) return bordered;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: bordered),
    );
  }
}

/// Small uppercase badge used inline in row trailing slots ("Tidak bisa
/// diubah", "Terhubung", etc.).
class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const Pill({
    super.key,
    required this.label,
    this.color = MoriColors.accent,
    Color? background,
  }) : background = background ?? const Color(0x2114B8A6); // accent @ 0.13

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.text.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// 42×26 pill toggle matching the design (accent on, panel3 off, white
/// thumb with soft shadow). Tap target widened to 48 via padding.
class MoriToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const MoriToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 42,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? MoriColors.accent : mori.panel3,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFFFE),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
