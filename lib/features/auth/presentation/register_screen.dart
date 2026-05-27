import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_error.dart';
import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../shared/widgets/m_button.dart';
import '../../../shared/widgets/m_error_banner.dart';
import '../../../shared/widgets/m_text_field.dart';
import '../../../theme/mori_spacing.dart';
import '../application/auth_controller.dart';
import '_auth_form_helpers.dart';
import '_auth_shell.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _submitting = false;
  String? _banner;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _banner = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            username: _username.text.trim(),
            password: _password.text,
            name: _name.text.trim().isEmpty ? null : _name.text.trim(),
          );
      // Router redirect picks up authenticated state and navigates to
      // /onboarding automatically — no explicit push needed here.
    } on AppError catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _banner = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _banner = CopyId.errNetwork;
      });
    }
  }

  void _dismissBanner() => setState(() => _banner = null);

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: AutofillGroup(
        child: AuthShell(
          title: 'Daftar',
          subtitle: 'Buat akun untuk simpan jadwal di semua perangkat kamu.',
          body: [
            if (_banner != null) ...[
              MErrorBanner(message: _banner!, onDismiss: _dismissBanner),
              const SizedBox(height: MoriSpacing.s3),
            ],
            MTextField(
              controller: _username,
              label: 'Username',
              hint: 'your_username',
              helperText: '8-30 karakter, huruf/angka/underscore',
              monospace: true,
              showValidIndicator: true,
              enabled: !_submitting,
              autofillHints: const [AutofillHints.username],
              inputFormatters: [AuthValidators.usernameFormatter],
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.username,
              maxLength: 30,
            ),
            const SizedBox(height: MoriSpacing.s3),
            MTextField(
              controller: _password,
              label: 'Password',
              hint: '••••••••',
              helperText: 'Minimal 8 karakter',
              obscureText: true,
              showValidIndicator: true,
              enabled: !_submitting,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: MoriSpacing.s3),
            MTextField(
              controller: _name,
              label: 'Nama Panggilan',
              labelMeta: 'opsional',
              hint: 'Nama panggilan kamu di Mori',
              helperText: 'Yang Mori pakai untuk sapa kamu',
              enabled: !_submitting,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MButton(
                label: _submitting ? CopyId.mendaftar : CopyId.daftar,
                onPressed: _submitting ? null : _submit,
                loading: _submitting,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: context.text.bodyMedium?.copyWith(
                      color: mori.muted,
                      fontSize: 13.5,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _submitting
                        ? null
                        : () {
                            if (context.canPop()) context.pop();
                            context.push('/login');
                          },
                    child: Text(
                      'Login di sini',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.cs.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
