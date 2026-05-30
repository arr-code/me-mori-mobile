import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../shared/extensions/date_id.dart';
import '../../../shared/widgets/m_error_banner.dart';
import '../../../shared/widgets/mori_icon.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/auth_state.dart';
import '../application/chat_controller.dart';
import '../application/chat_state.dart';
import 'action_card_view.dart';
import 'bubble.dart';
import 'typing_dots.dart';

/// Phase 4 — Chat & Action Cards.
///
/// Composer pinned above the keyboard (`MediaQuery.viewInsets.bottom`),
/// auto-scrolls on every message change. Cards are inline; resolved
/// status replaces the action buttons in place.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  bool _hasDraft = false;

  @override
  void initState() {
    super.initState();
    _input.addListener(() {
      final hasDraft = _input.text.trim().isNotEmpty;
      if (hasDraft != _hasDraft) setState(() => _hasDraft = hasDraft);
    });
    // Hydrate transcript from GET /api/chat/turns on first mount. Safe
    // to call even if state already has items — replaces in-place.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    setState(() => _hasDraft = false);
    await ref.read(chatControllerProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChatState>(chatControllerProvider, (prev, next) {
      if ((prev?.items.length ?? 0) != next.items.length) {
        _scrollToBottom();
      }
    });

    final state = ref.watch(chatControllerProvider);
    final user = switch (ref.watch(authControllerProvider)) {
      Authenticated(user: final u) => u,
      _ => null,
    };

    return Scaffold(
      // Composer handles its own keyboard inset via Padding — Scaffold's
      // default resize would also work but the composer's border-top
      // looks cleaner when we control it directly.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ChatHeader(
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/home'),
              onRestart: () =>
                  ref.read(chatControllerProvider.notifier).restart(),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: MErrorBanner(
                  message: state.error!,
                  onDismiss: () =>
                      ref.read(chatControllerProvider.notifier).clearError(),
                ),
              ),
            Expanded(
              child: _MessageList(
                scroll: _scroll,
                items: state.items,
                emptyGreetingName: user?.name,
              ),
            ),
            _Composer(
              controller: _input,
              focusNode: _inputFocus,
              hasDraft: _hasDraft,
              sending: state.sending,
              onSubmit: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRestart;

  const _ChatHeader({required this.onBack, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: mori.borderSo)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: mori.muted,
            tooltip: 'Kembali',
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          const MoriIcon(size: 34, radius: 9),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mori',
                  style: context.text.titleLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: MoriColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      CopyId.chatHeaderStatus,
                      style: context.text.bodySmall?.copyWith(
                        fontSize: 11,
                        color: MoriColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Mulai ulang percakapan',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRestart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: mori.panel2,
                  border: Border.all(color: mori.border),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restart_alt_rounded,
                        size: 12, color: mori.muted),
                    const SizedBox(width: 4),
                    Text(
                      CopyId.chatRestart,
                      style: context.text.bodySmall?.copyWith(
                        fontSize: 11,
                        color: mori.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message list ────────────────────────────────────────────────────────

class _MessageList extends ConsumerWidget {
  final ScrollController scroll;
  final List<ChatItem> items;
  final String? emptyGreetingName;

  const _MessageList({
    required this.scroll,
    required this.items,
    required this.emptyGreetingName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return _EmptyGreeting(name: emptyGreetingName);
    }

    return ListView.separated(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        if (i == 0) return _ContextDivider(time: items.first.createdAt);
        final item = items[i - 1];
        // Keyed by item id so Flutter preserves element identity when
        // typing → mori bubble + card replaces typing → enter animation
        // only fires for genuinely new entries, not when state mutates.
        return KeyedSubtree(
          key: ValueKey(item.id),
          child: _AppearAnimation(child: _ItemView(item: item)),
        );
      },
    );
  }
}

class _ContextDivider extends StatelessWidget {
  final DateTime time;
  const _ContextDivider({required this.time});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '${DateId.heroDate(time)} · ${DateId.time(time)}',
          style: context.text.bodySmall?.copyWith(
            fontSize: 11,
            color: context.mori.dim,
          ),
        ),
      ),
    );
  }
}

class _EmptyGreeting extends StatelessWidget {
  final String? name;
  const _EmptyGreeting({required this.name});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final n = (name == null || name!.isEmpty) ? 'kamu' : name!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Text(
            'Halo, $n.',
            style: context.text.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Ada yang Mori bantu?',
            style: context.text.bodyMedium?.copyWith(
              color: mori.muted,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Plays a 200ms fade-in + slight scale-up the first time the child
/// mounts. Combined with the keyed list builder above, this only fires
/// for genuinely new chat entries (user bubble, typing indicator, mori
/// reply, action card) — existing items don't replay on state changes.
class _AppearAnimation extends StatelessWidget {
  final Widget child;
  const _AppearAnimation({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (_, t, c) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.96 + 0.04 * t,
          alignment: Alignment.centerLeft,
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _ItemView extends ConsumerWidget {
  final ChatItem item;
  const _ItemView({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (item) {
      case UserMessageItem u:
        return Bubble(side: BubbleSide.me, text: u.text, time: u.createdAt);
      case MoriMessageItem m:
        return Bubble(side: BubbleSide.mori, text: m.text, time: m.createdAt);
      case TypingItem t:
        return TypingDots(startedAt: t.createdAt);
      case ActionCardItem a:
        return ActionCardView(
          action: a.action,
          status: a.status,
          submitting: a.submitting,
          onDecide: (decision) => ref
              .read(chatControllerProvider.notifier)
              .decide(a.id, decision),
        );
    }
  }
}

// ── Composer ────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasDraft;
  final bool sending;
  final VoidCallback onSubmit;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.hasDraft,
    required this.sending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final sendEnabled = hasDraft && !sending;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: mori.borderSo)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, MoriSpacing.s2),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            decoration: BoxDecoration(
              color: context.cs.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: hasDraft ? MoriColors.accent : mori.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: !sending,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.multiline,
                    style: context.text.bodyLarge?.copyWith(
                      fontSize: 14.5,
                      letterSpacing: -0.1,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                      hintText: CopyId.chatComposerHint,
                      hintStyle: context.text.bodyLarge?.copyWith(
                        fontSize: 14.5,
                        color: mori.dim,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => onSubmit(),
                  ),
                ),
                const SizedBox(width: 6),
                _SendButton(enabled: sendEnabled, onTap: onSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _SendButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Kirim pesan',
      child: Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? MoriColors.accent : mori.panel2,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.send_rounded,
            size: 16,
            color: enabled ? MoriColors.accentFg : mori.dim,
          ),
        ),
      ),
    ),
    );
  }
}
