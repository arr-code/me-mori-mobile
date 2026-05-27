import 'package:flutter/material.dart';

import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../theme/mori_colors.dart';

/// Three staggered bouncing dots + a label that progresses as time
/// elapses since [startedAt]:
///   0–1.5s   "Mori berpikir"
///   1.5–3.5s "merangkum konteks"
///   3.5–6.5s "menyiapkan aksi"
///   6.5s+    "menyelesaikan"
/// Per design §5.4 typing indicator spec.
class TypingDots extends StatefulWidget {
  final DateTime startedAt;

  const TypingDots({super.key, required this.startedAt});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _labelFor(Duration elapsed) {
    final ms = elapsed.inMilliseconds;
    if (ms < 1500) return CopyId.chatTypingLabel1;
    if (ms < 3500) return CopyId.chatTypingLabel2;
    if (ms < 6500) return CopyId.chatTypingLabel3;
    return CopyId.chatTypingLabel4;
  }

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: mori.borderSo),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
                  child: _Dot(controller: _ctrl, phase: i * 0.15),
                );
              }),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final label = _labelFor(
                  DateTime.now().difference(widget.startedAt),
                );
                return Text(
                  label,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 12,
                    color: mori.muted,
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController controller;
  final double phase; // 0–1 fraction of period

  const _Dot({required this.controller, required this.phase});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        // Shifted sine wave: dot rises mid-cycle, settles at edges.
        final t = (controller.value + phase) % 1.0;
        // Range [0..1] mapped to [0..1..0] via sine.
        final amp = (t < 0.4)
            ? (t / 0.4) // climbing
            : (t < 0.7)
                ? 1 - ((t - 0.4) / 0.3) // falling
                : 0.0; // resting
        return Transform.translate(
          offset: Offset(0, -4 * amp),
          child: Opacity(
            opacity: 0.4 + 0.6 * amp,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: MoriColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
