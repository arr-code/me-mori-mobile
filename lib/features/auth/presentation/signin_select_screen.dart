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
import '../../../shared/widgets/mori_icon.dart';
import '../../../shared/widgets/mori_wordmark.dart';
import '../../../theme/mori_spacing.dart';
import '../application/auth_controller.dart';
import '../application/auth_state.dart';
import '_auth_bg.dart';
import 'google_web_button.dart';

/// Design's `02 Pilih cara masuk` — entry point post-welcome.
/// Google login is the secondary (low-friction) option; "Daftar dengan Email"
/// is the primary CTA. Bottom holds a "Sudah punya akun? Login" link and the
/// ToS / Privacy line.
class SignInSelectScreen extends ConsumerStatefulWidget {
  const SignInSelectScreen({super.key});

  @override
  ConsumerState<SignInSelectScreen> createState() => _SignInSelectScreenState();
}

class _SignInSelectScreenState extends ConsumerState<SignInSelectScreen> {
  bool _loadingGoogle = false;
  String? _formError;

  Future<void> _onGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _formError = null;
    });
    try {
      final ok =
          await ref.read(authControllerProvider.notifier).signInWithGoogle();
      if (!ok && mounted) setState(() => _loadingGoogle = false);
    } on AppError catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingGoogle = false;
        _formError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingGoogle = false;
        _formError = CopyId.errNetwork;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notice = switch (ref.watch(authControllerProvider)) {
      Unauthenticated(notice: final n) => n,
      _ => null,
    };
    final banner = _formError ?? notice;
    final mori = context.mori;

    return Scaffold(
      body: AuthGradientBg(
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(28, 120, 28, 48),
          child: LayoutBuilder(
            builder: (context, c) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandBlock(),
                        const Spacer(),
                        if (banner != null) ...[
                          MErrorBanner(message: banner),
                          const SizedBox(height: MoriSpacing.s3),
                        ],
                        if (kIsWeb)
                          Center(child: googleWebButton())
                        else
                          MButton(
                            label: CopyId.lanjutGoogle,
                            onPressed: _loadingGoogle ? null : _onGoogle,
                            loading: _loadingGoogle,
                            leadingIcon: PhosphorIconsRegular.googleLogo,
                            variant: MButtonVariant.secondary,
                          ),
                        const SizedBox(height: MoriSpacing.s3),
                        _OrDivider(
                          color: mori.border,
                          label: 'atau',
                          dim: mori.dim,
                        ),
                        const SizedBox(height: MoriSpacing.s3),
                        MButton(
                          label: 'Daftar dengan Email',
                          onPressed: () => context.push('/register'),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Wrap(
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
                                onTap: () => context.push('/login'),
                                child: Text(
                                  CopyId.login,
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.cs.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _LegalFooter(muted: mori.muted, dim: mori.dim),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Column(
      children: [
        const MoriIcon(size: 104, glow: true),
        const SizedBox(height: 22),
        const MoriWordmark(size: 32),
        const SizedBox(height: 8),
        Text(
          'Asisten jadwal & pengingat',
          style: context.text.bodyMedium?.copyWith(
            color: mori.muted,
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  final Color color;
  final Color dim;
  final String label;

  const _OrDivider({
    required this.color,
    required this.dim,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MoriSpacing.s3),
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(color: dim, fontSize: 12),
          ),
        ),
        Expanded(child: Container(height: 1, color: color)),
      ],
    );
  }
}

class _LegalFooter extends StatelessWidget {
  final Color muted;
  final Color dim;
  const _LegalFooter({required this.muted, required this.dim});

  @override
  Widget build(BuildContext context) {
    final base = context.text.bodySmall?.copyWith(
      color: dim,
      fontSize: 11.5,
      height: 1.5,
    );
    final emphasis = base?.copyWith(color: muted);
    return Center(
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            const TextSpan(text: 'Dengan melanjutkan, kamu setuju dengan '),
            TextSpan(text: 'Syarat', style: emphasis),
            const TextSpan(text: ' dan '),
            TextSpan(text: 'Kebijakan Privasi', style: emphasis),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
