import 'package:flutter/material.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../shared/extensions/date_id.dart';
import '../../../theme/mori_colors.dart';

enum BubbleSide { me, mori }

/// Single message bubble. The "me" variant uses a teal gradient with a
/// sharp bottom-right corner; the "mori" variant uses panel-colour with
/// a sharp bottom-left corner. Per design `05 Chat`.
class Bubble extends StatelessWidget {
  final BubbleSide side;
  final String text;
  final DateTime time;

  const Bubble({
    super.key,
    required this.side,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final me = side == BubbleSide.me;
    final mori = context.mori;

    final radius = me
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: me
                    ? const LinearGradient(
                        begin: Alignment(-0.3, -1),
                        end: Alignment(0.5, 1),
                        colors: [MoriColors.accent, MoriColors.accentSo],
                      )
                    : null,
                color: me ? null : context.cs.surface,
                borderRadius: radius,
                border: me
                    ? null
                    : Border.all(color: mori.borderSo),
                boxShadow: me
                    ? [
                        BoxShadow(
                          color: MoriColors.accent.withValues(alpha: 0.45),
                          blurRadius: 16,
                          spreadRadius: -6,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                text,
                style: context.text.bodyLarge?.copyWith(
                  fontSize: 14.5,
                  height: 1.45,
                  letterSpacing: -0.1,
                  fontWeight: me ? FontWeight.w500 : FontWeight.w400,
                  color: me ? MoriColors.accentFg : context.cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                me ? DateId.time(time) : 'Mori · ${DateId.time(time)}',
                style: context.text.bodySmall?.copyWith(
                  fontSize: 10.5,
                  color: mori.dim,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
