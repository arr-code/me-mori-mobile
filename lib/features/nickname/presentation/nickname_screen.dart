import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../shared/widgets/m_button.dart';
import '../../../shared/widgets/m_error_banner.dart';
import '../../../shared/widgets/mori_icon.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/auth_state.dart';
import '../application/nickname_controller.dart';
import '../application/nickname_suggestions.dart';

/// Design's `06 Panggilan` — chat-style nickname prompt sandwiched
/// between auth and the multi-step profile onboarding.
///
/// Layout (top → bottom):
///   - Top bar: brand icon + "Kenalan dulu" + progress "1 dari 5"
///   - Progress bar 4 px @ 20% accent fill
///   - Two stacked Mori bubbles (greeting + ask)
///   - Suggestion chips parsed from the user's current formal name
///   - Bottom sticky: live preview (when there's a value) + input row
///     + "Lewati / Lanjut" CTAs
class NicknameScreen extends ConsumerStatefulWidget {
  const NicknameScreen({super.key});

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _submitting = false;
  String? _banner;

  static const int _maxLength = 24;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _value => _controller.text.trim();
  bool get _hasValue => _value.isNotEmpty;

  void _pickSuggestion(String s) {
    _controller.value = TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
    _focusNode.requestFocus();
  }

  Future<void> _onContinue() async {
    if (!_hasValue) return;
    setState(() {
      _submitting = true;
      _banner = null;
    });
    try {
      await ref.read(nicknameControllerProvider).save(_value);
      // Router watches `nicknamePromptSeenProvider`; flipping it forwards
      // the user to /onboarding automatically.
    } on AppError catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _banner = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _banner = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : CopyId.errNetwork;
      });
    }
  }

  void _onSkip() {
    ref.read(nicknameControllerProvider).skip();
  }

  @override
  Widget build(BuildContext context) {
    final user = switch (ref.watch(authControllerProvider)) {
      Authenticated(user: final u) => u,
      _ => null,
    };
    final fullName = user?.name ?? '';
    final suggestions = suggestNicknames(fullName);
    final mori = context.mori;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(),
            const _ProgressBar(fraction: 0.20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                children: [
                  _GreetingBubble(text: CopyId.nicknameGreetingFirst),
                  const SizedBox(height: 10),
                  _AskBubble(fullName: fullName),
                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _SuggestionsHeader(),
                    const SizedBox(height: 10),
                    _SuggestionChips(
                      suggestions: suggestions,
                      selectedValue: _value,
                      onPick: _pickSuggestion,
                    ),
                  ],
                ],
              ),
            ),
            _BottomBar(
              controller: _controller,
              focusNode: _focusNode,
              hasValue: _hasValue,
              submitting: _submitting,
              banner: _banner,
              maxLength: _maxLength,
              previewValue: _value,
              previewBgColor: MoriColors.accent.withValues(alpha: 0.10),
              previewBorderColor: MoriColors.accent.withValues(alpha: 0.30),
              mutedColor: mori.muted,
              dimColor: mori.dim,
              onDismissBanner: () => setState(() => _banner = null),
              onContinue: _onContinue,
              onSkip: _submitting ? null : _onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar + progress ──────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          const MoriIcon(size: 28),
          const SizedBox(width: 10),
          Text(
            CopyId.nicknameTopTitle,
            style: context.text.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            CopyId.nicknameProgress,
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
  final double fraction;
  const _ProgressBar({required this.fraction});

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
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
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

// ── Bubbles ─────────────────────────────────────────────────────────────

class _GreetingBubble extends StatelessWidget {
  final String text;
  const _GreetingBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const MoriIcon(size: 36, radius: 9),
        const SizedBox(width: 10),
        Flexible(child: _MoriBubble(text: text)),
      ],
    );
  }
}

class _AskBubble extends StatelessWidget {
  final String fullName;
  const _AskBubble({required this.fullName});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final hasFullName = fullName.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 36),
        const SizedBox(width: 10),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.88,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.cs.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: mori.borderSo),
              ),
              child: hasFullName
                  ? Text.rich(
                      TextSpan(
                        style: context.text.bodyLarge?.copyWith(
                          fontSize: 14.5,
                          height: 1.5,
                          letterSpacing: -0.1,
                        ),
                        children: [
                          const TextSpan(text: CopyId.nicknameGreetingFormalLead),
                          TextSpan(
                            text: fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: CopyId.nicknameGreetingFormalTail),
                        ],
                      ),
                    )
                  : Text(
                      CopyId.nicknameGreetingFallback,
                      style: context.text.bodyLarge?.copyWith(
                        fontSize: 14.5,
                        height: 1.5,
                        letterSpacing: -0.1,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoriBubble extends StatelessWidget {
  final String text;
  const _MoriBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.82,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cs.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: mori.borderSo),
        ),
        child: Text(
          text,
          style: context.text.bodyLarge?.copyWith(
            fontSize: 14.5,
            height: 1.45,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ── Suggestion chips ────────────────────────────────────────────────────

class _SuggestionsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 46),
      child: Text(
        CopyId.nicknameSuggestionsLabel.toUpperCase(),
        style: context.text.labelSmall?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: context.mori.dim,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final String selectedValue;
  final ValueChanged<String> onPick;

  const _SuggestionChips({
    required this.suggestions,
    required this.selectedValue,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 46),
      child: Wrap(
        spacing: MoriSpacing.s2,
        runSpacing: MoriSpacing.s2,
        children: [
          for (final s in suggestions)
            _Chip(label: s, selected: s == selectedValue, onTap: () => onPick(s)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? MoriColors.accent : mori.panel2,
            border: Border.all(
              color: selected ? Colors.transparent : mori.border,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: MoriColors.accent.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: -6,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: MoriColors.accentFg,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? MoriColors.accentFg
                      : context.cs.onSurface,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ──────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasValue;
  final bool submitting;
  final String? banner;
  final int maxLength;
  final String previewValue;
  final Color previewBgColor;
  final Color previewBorderColor;
  final Color mutedColor;
  final Color dimColor;
  final VoidCallback onDismissBanner;
  final VoidCallback onContinue;
  final VoidCallback? onSkip;

  const _BottomBar({
    required this.controller,
    required this.focusNode,
    required this.hasValue,
    required this.submitting,
    required this.banner,
    required this.maxLength,
    required this.previewValue,
    required this.previewBgColor,
    required this.previewBorderColor,
    required this.mutedColor,
    required this.dimColor,
    required this.onDismissBanner,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: mori.borderSo)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, MoriSpacing.s4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (banner != null) ...[
                MErrorBanner(message: banner!, onDismiss: onDismissBanner),
                const SizedBox(height: MoriSpacing.s3),
              ],
              if (hasValue) ...[
                _Preview(
                  text: previewValue,
                  bgColor: previewBgColor,
                  borderColor: previewBorderColor,
                ),
                const SizedBox(height: MoriSpacing.s3),
              ],
              _InputRow(
                controller: controller,
                focusNode: focusNode,
                maxLength: maxLength,
                onSubmitted: hasValue && !submitting ? onContinue : null,
                enabled: !submitting,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  CopyId.nicknameFieldHelp,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 12,
                    color: dimColor,
                  ),
                ),
              ),
              const SizedBox(height: MoriSpacing.s3),
              Row(
                children: [
                  MButton(
                    label: CopyId.nicknameSkip,
                    variant: MButtonVariant.ghost,
                    size: MButtonSize.lg,
                    fullWidth: false,
                    onPressed: onSkip,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MButton(
                      label: submitting
                          ? CopyId.onboardingSubmitting
                          : CopyId.nicknameContinue,
                      size: MButtonSize.lg,
                      loading: submitting,
                      onPressed:
                          (hasValue && !submitting) ? onContinue : null,
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

class _Preview extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color borderColor;

  const _Preview({
    required this.text,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            size: 14,
            color: MoriColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: CopyId.nicknamePreviewLead),
                  TextSpan(
                    text: '"Halo, $text"',
                    style: const TextStyle(
                      color: MoriColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;
  final VoidCallback? onSubmitted;
  final bool enabled;

  const _InputRow({
    required this.controller,
    required this.focusNode,
    required this.maxLength,
    required this.onSubmitted,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final hasText = controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          CopyId.nicknameFieldLabel.toUpperCase(),
          style: context.text.labelSmall?.copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: mori.muted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: context.cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasText ? MoriColors.accent : mori.border,
              width: 1.5,
            ),
            boxShadow: hasText
                ? [
                    BoxShadow(
                      color: MoriColors.accent.withValues(alpha: 0.12),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  autofocus: false,
                  maxLength: maxLength,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  style: context.text.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                  cursorColor: MoriColors.accent,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: CopyId.nicknameFieldHint,
                    hintStyle: context.text.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: mori.dim,
                      letterSpacing: -0.2,
                    ),
                  ),
                  onSubmitted:
                      onSubmitted == null ? null : (_) => onSubmitted!(),
                ),
              ),
              Text(
                '${controller.text.length}/$maxLength',
                style: context.text.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: mori.dim,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
