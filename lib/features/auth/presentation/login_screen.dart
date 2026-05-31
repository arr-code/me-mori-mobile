import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
import 'google_web_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool _googleSubmitting = false;
  String? _banner;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _banner = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(
            username: _username.text.trim(),
            password: _password.text,
          );
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

  Future<void> _onGoogle() async {
    setState(() {
      _googleSubmitting = true;
      _banner = null;
    });
    try {
      final ok =
          await ref.read(authControllerProvider.notifier).signInWithGoogle();
      if (!ok && mounted) setState(() => _googleSubmitting = false);
    } on AppError catch (e) {
      if (!mounted) return;
      setState(() {
        _googleSubmitting = false;
        _banner = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _googleSubmitting = false;
        _banner = CopyId.errNetwork;
      });
    }
  }

  void _dismissBanner() => setState(() => _banner = null);

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final anyBusy = _submitting || _googleSubmitting;

    return Form(
      key: _formKey,
      // Login does NOT autovalidate — the only meaningful error comes from
      // the server. Validating format live would leak that a username
      // "looks valid", which the server would then either accept or reject.
      child: AutofillGroup(
        child: AuthShell(
          title: CopyId.login,
          subtitle: 'Lanjutkan ke jadwal kamu.',
          body: [
            if (_banner != null) ...[
              MErrorBanner(message: _banner!, onDismiss: _dismissBanner),
              const SizedBox(height: MoriSpacing.s3),
            ],
            MTextField(
              controller: _username,
              label: 'Username',
              hint: 'username kamu',
              monospace: true,
              enabled: !anyBusy,
              autofillHints: const [AutofillHints.username],
              inputFormatters: [AuthValidators.usernameFormatter],
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              maxLength: 30,
            ),
            const SizedBox(height: MoriSpacing.s3),
            MTextField(
              controller: _password,
              label: 'Password',
              hint: '••••••••',
              obscureText: true,
              enabled: !anyBusy,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MButton(
                label: _submitting ? CopyId.masuk : CopyId.login,
                onPressed: anyBusy ? null : _submit,
                loading: _submitting,
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: context.text.bodyMedium?.copyWith(
                      color: mori.muted,
                      fontSize: 13.5,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: anyBusy
                        ? null
                        : () {
                            if (context.canPop()) context.pop();
                            context.push('/register');
                          },
                    child: Text(
                      'Daftar di sini',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.cs.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: mori.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau',
                      style: context.text.bodySmall?.copyWith(
                        color: mori.dim,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: mori.border)),
                ],
              ),
              const SizedBox(height: 14),
              if (kIsWeb)
                Center(child: googleWebButton())
              else
                MButton(
                  label: 'Login dengan Google',
                  onPressed: anyBusy ? null : _onGoogle,
                  loading: _googleSubmitting,
                  leadingIcon: PhosphorIconsRegular.googleLogo,
                  variant: MButtonVariant.secondary,
                  size: MButtonSize.md,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
