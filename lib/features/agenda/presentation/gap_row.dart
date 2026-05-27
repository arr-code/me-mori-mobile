import 'package:flutter/material.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../shared/extensions/date_id.dart';
import '../../../theme/mori_spacing.dart';

/// Empty-slot row between two agenda items. Indents past the time column
/// (64 px) so it visually sits inside the timeline.
class GapRow extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final String? label;

  const GapRow({
    super.key,
    required this.from,
    required this.to,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final duration = to.difference(from);
    final dur = DateId.durationShort(duration);
    final range = DateId.timeRange(from, to);
    final lbl = label ?? 'Kosong';

    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 6, 0, 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mori.border,
            ),
          ),
          const SizedBox(width: MoriSpacing.s3),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$lbl · $dur'),
                  TextSpan(
                    text: '  ·  $range',
                    style: TextStyle(color: mori.dim.withValues(alpha: 0.7)),
                  ),
                ],
              ),
              style: context.text.bodySmall?.copyWith(
                fontSize: 12,
                color: mori.dim,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
