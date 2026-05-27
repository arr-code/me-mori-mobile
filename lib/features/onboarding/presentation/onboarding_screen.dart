import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../shared/widgets/m_button.dart';
import '../../../shared/widgets/m_error_banner.dart';
import '../../../shared/widgets/m_text_field.dart';
import '../../../shared/widgets/mori_icon.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../../auth/application/auth_controller.dart';
import '../application/onboarding_controller.dart';

/// Design's `06 Onboarding`. Single-screen profile setup with a 5-field
/// progress indicator and a sticky bottom action bar.
///
/// Required fields: profession, goals, working pattern.
/// Optional:        personal rules, bio.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profession = TextEditingController();
  final _goals = TextEditingController();
  final _workingPattern = TextEditingController();
  final _personalRules = TextEditingController();
  final _bio = TextEditingController();

  bool _submitting = false;
  String? _banner;

  @override
  void initState() {
    super.initState();
    for (final c in _allControllers) {
      c.addListener(_onAnyChange);
    }
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onAnyChange);
      c.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _allControllers =>
      [_profession, _goals, _workingPattern, _personalRules, _bio];

  void _onAnyChange() => setState(() {});

  int get _filledCount =>
      _allControllers.where((c) => c.text.trim().isNotEmpty).length;

  String? _requiredValidator(String? raw) {
    if ((raw ?? '').trim().isEmpty) return CopyId.onboardingFieldRequired;
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _banner = null;
    });
    try {
      await ref.read(onboardingControllerProvider).submit(
            profession: _profession.text,
            goals: _goals.text,
            workingPattern: _workingPattern.text,
            personalRules: _personalRules.text,
            bio: _bio.text,
          );
      // Router redirect picks up user.hasCompletedOnboarding and navigates
      // to /home — no explicit go() needed here.
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

  Future<void> _logoutAndReturn() async {
    // "Kembali" in a single-screen onboarding can only mean leaving the
    // authenticated session — the router would otherwise force the user
    // straight back here. Confirm to avoid accidental session loss.
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Mori?'),
        content: const Text(
          'Kamu akan kembali ke layar masuk. Jadwal yang sudah Mori siapkan tetap aman.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CopyId.batal),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final filled = _filledCount;

    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(filled: filled),
              _ProgressBar(value: filled / 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  children: [
                    Text(
                      CopyId.onboardingHeroTitle,
                      style: context.text.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CopyId.onboardingHeroSubtitle,
                      style: context.text.bodyMedium?.copyWith(
                        color: mori.muted,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_banner != null) ...[
                      MErrorBanner(
                        message: _banner!,
                        onDismiss: () => setState(() => _banner = null),
                      ),
                      const SizedBox(height: MoriSpacing.s4),
                    ],
                    MTextField(
                      controller: _profession,
                      label: CopyId.onboardingFieldProfesi,
                      hint: CopyId.onboardingFieldProfesiHint,
                      enabled: !_submitting,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: MoriSpacing.s4),
                    MTextField(
                      controller: _goals,
                      label: CopyId.onboardingFieldTujuan,
                      hint: CopyId.onboardingFieldTujuanHint,
                      enabled: !_submitting,
                      maxLines: 4,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: MoriSpacing.s4),
                    MTextField(
                      controller: _workingPattern,
                      label: CopyId.onboardingFieldPolaKerja,
                      hint: CopyId.onboardingFieldPolaKerjaHint,
                      enabled: !_submitting,
                      maxLines: 4,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: MoriSpacing.s4),
                    MTextField(
                      controller: _personalRules,
                      label: CopyId.onboardingFieldAturan,
                      labelMeta: 'opsional',
                      hint: CopyId.onboardingFieldAturanHint,
                      helperText: CopyId.onboardingFieldAturanHelp,
                      enabled: !_submitting,
                      maxLines: 3,
                      minLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: MoriSpacing.s4),
                    MTextField(
                      controller: _bio,
                      label: CopyId.onboardingFieldBio,
                      labelMeta: 'opsional',
                      hint: CopyId.onboardingFieldBioHint,
                      enabled: !_submitting,
                      maxLines: 3,
                      minLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
              _BottomBar(
                submitting: _submitting,
                onBack: _submitting ? null : _logoutAndReturn,
                onSubmit: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int filled;
  const _TopBar({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          const MoriIcon(size: 28),
          const SizedBox(width: 10),
          Text(
            CopyId.onboardingTopTitle,
            style: context.text.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '$filled dari 5',
            style: context.text.bodySmall?.copyWith(
              color: context.mori.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MoriRadius.pill),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [
              Container(color: context.mori.panel2),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                widthFactor: value.clamp(0.0, 1.0),
                heightFactor: 1,
                child: Container(color: MoriColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool submitting;
  final VoidCallback? onBack;
  final VoidCallback? onSubmit;

  const _BottomBar({
    required this.submitting,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: mori.borderSo),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, MoriSpacing.s4),
          child: Row(
            children: [
              MButton(
                label: CopyId.onboardingKembali,
                variant: MButtonVariant.ghost,
                size: MButtonSize.lg,
                fullWidth: false,
                onPressed: onBack,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MButton(
                  label: submitting
                      ? CopyId.onboardingSubmitting
                      : CopyId.onboardingSubmit,
                  size: MButtonSize.lg,
                  loading: submitting,
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
