import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/mori_colors.dart';
import '../../theme/mori_spacing.dart';
import '../../theme/mori_typography.dart';
import '../extensions/context_theme.dart';

class MTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;

  /// Optional trailing meta beside the label, rendered in the same row.
  /// Use this for "· opsional" affordances next to the uppercase label.
  final String? labelMeta;
  final String? hint;
  final String? helperText;
  final String? errorText;

  /// Show a green check chip on the right side when the field is non-empty
  /// and has no error. Useful for the register flow (username/password).
  final bool showValidIndicator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool monospace;
  final bool autofocus;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const MTextField({
    super.key,
    this.controller,
    this.label,
    this.labelMeta,
    this.hint,
    this.helperText,
    this.errorText,
    this.showValidIndicator = false,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.monospace = false,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<MTextField> createState() => _MTextFieldState();
}

class _MTextFieldState extends State<MTextField> {
  late bool _obscured;
  late TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(MTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onTextChange);
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
      _controller.addListener(_onTextChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChange() {
    if (widget.showValidIndicator) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final textTheme = context.text;

    final baseStyle = widget.monospace
        ? MoriTypography.mono(
            size: 15,
            weight: FontWeight.w500,
            color: context.cs.onSurface,
          )
        : textTheme.bodyLarge;

    final showValid = widget.showValidIndicator &&
        widget.errorText == null &&
        _controller.text.trim().isNotEmpty;
    final showError = widget.errorText != null;

    Widget? trailing;
    if (showError) {
      trailing = _IndicatorChip(
        bg: context.cs.error.withValues(alpha: 0.18),
        fg: context.cs.error,
        icon: Icons.close_rounded,
      );
    } else if (showValid) {
      trailing = _IndicatorChip(
        bg: mori.ok.withValues(alpha: 0.18),
        fg: mori.ok,
        icon: Icons.check_rounded,
      );
    }

    Widget? suffixWidget = widget.suffix;
    if (widget.obscureText) {
      suffixWidget = IconButton(
        splashRadius: 20,
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: mori.muted,
          size: 20,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    // If we have both an indicator (valid/error) and a suffix (eye toggle),
    // stack them inline. Indicator sits at the right of the field.
    Widget? combinedSuffix;
    if (suffixWidget != null && trailing != null) {
      combinedSuffix = Row(
        mainAxisSize: MainAxisSize.min,
        children: [trailing, suffixWidget],
      );
    } else {
      combinedSuffix = suffixWidget ?? trailing;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  widget.label!.toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: mori.muted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                if (widget.labelMeta != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '· ${widget.labelMeta!}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: mori.dim,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          obscureText: _obscured,
          obscuringCharacter: '•',
          maxLines: _obscured ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          autocorrect: !widget.monospace && !widget.obscureText,
          enableSuggestions: !widget.monospace && !widget.obscureText,
          style: baseStyle,
          cursorColor: MoriColors.accent,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            counterText: '',
            filled: true,
            fillColor: mori.panel2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MoriSpacing.s4,
              vertical: MoriSpacing.s3,
            ),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, color: mori.muted, size: 20),
            suffixIcon: combinedSuffix,
          ),
        ),
      ],
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;

  const _IndicatorChip({
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: MoriSpacing.s2),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 12, color: fg),
      ),
    );
  }
}
