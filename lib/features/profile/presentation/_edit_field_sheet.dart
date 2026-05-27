import 'package:flutter/material.dart';

import '../../../core/error/app_error.dart';
import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../shared/widgets/m_button.dart';
import '../../../shared/widgets/m_error_banner.dart';
import '../../../shared/widgets/m_text_field.dart';
import '../../../theme/mori_spacing.dart';

/// Modal bottom sheet used by [ProfileScreen] for inline edits. Keeps a
/// single text field + Simpan / Batal buttons. Surfaces validation +
/// network errors with [MErrorBanner].
class EditFieldSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String fieldLabel;
  final String? fieldHint;
  final String? helperText;
  final String? initialValue;
  final bool required;
  final bool multiline;
  final int? maxLength;
  final TextInputType? keyboardType;
  final Future<void> Function(String value) onSave;

  const EditFieldSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.fieldLabel,
    this.fieldHint,
    this.helperText,
    this.initialValue,
    this.required = false,
    this.multiline = false,
    this.maxLength,
    this.keyboardType,
    required this.onSave,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String fieldLabel,
    String? fieldHint,
    String? helperText,
    String? initialValue,
    bool required = false,
    bool multiline = false,
    int? maxLength,
    TextInputType? keyboardType,
    required Future<void> Function(String value) onSave,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditFieldSheet(
        title: title,
        subtitle: subtitle,
        fieldLabel: fieldLabel,
        fieldHint: fieldHint,
        helperText: helperText,
        initialValue: initialValue,
        required: required,
        multiline: multiline,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<EditFieldSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _banner;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _banner = null;
    });
    try {
      await widget.onSave(_controller.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppError catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _banner = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _banner = e is Exception ? e.toString().replaceFirst('Exception: ', '') : CopyId.errNetwork;
      });
    }
  }

  String? _validator(String? raw) {
    if (!widget.required) return null;
    if ((raw ?? '').trim().isEmpty) return CopyId.onboardingFieldRequired;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mori.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: MoriSpacing.s4),
                Text(
                  widget.title,
                  style: context.text.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: context.text.bodyMedium?.copyWith(
                      color: mori.muted,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: MoriSpacing.s4),
                if (_banner != null) ...[
                  MErrorBanner(
                    message: _banner!,
                    onDismiss: () => setState(() => _banner = null),
                  ),
                  const SizedBox(height: MoriSpacing.s3),
                ],
                MTextField(
                  controller: _controller,
                  label: widget.fieldLabel,
                  hint: widget.fieldHint,
                  helperText: widget.helperText,
                  enabled: !_saving,
                  autofocus: true,
                  maxLength: widget.maxLength,
                  maxLines: widget.multiline ? 5 : 1,
                  minLines: widget.multiline ? 3 : 1,
                  keyboardType: widget.keyboardType,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: widget.multiline
                      ? TextInputAction.newline
                      : TextInputAction.done,
                  onSubmitted: widget.multiline ? null : (_) => _save(),
                  validator: _validator,
                ),
                const SizedBox(height: MoriSpacing.s4),
                Row(
                  children: [
                    Expanded(
                      child: MButton(
                        label: CopyId.batal,
                        variant: MButtonVariant.ghost,
                        size: MButtonSize.lg,
                        onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: MoriSpacing.s2),
                    Expanded(
                      child: MButton(
                        label: _saving ? CopyId.onboardingSubmitting : CopyId.simpan,
                        size: MButtonSize.lg,
                        loading: _saving,
                        onPressed: _saving ? null : _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
