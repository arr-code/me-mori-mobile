import 'package:flutter/material.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../shared/extensions/date_id.dart';
import '../../../shared/widgets/m_tag.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../data/models/agenda.dart';

/// Agenda card row used by HomeScreen list. Renders the design's three
/// visual states from a single [Agenda]:
///   - default
///   - `now` (ongoing): teal-tinted gradient + "Berlangsung" pill
///   - `done` (or past): 50% opacity + strikethrough title + "Selesai" badge
class AgendaRow extends StatelessWidget {
  final Agenda item;
  final VoidCallback? onTap;

  const AgendaRow({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final now = DateTime.now();
    final ongoing = item.isOngoing(now: now);
    final past = item.isPast(now: now);
    final dimmed = item.isDone || past;
    final accent = MoriColors.accent;

    return Opacity(
      opacity: dimmed ? 0.5 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Text(
                DateId.time(item.startTime),
                style: context.text.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ongoing ? accent : context.cs.onSurface,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
          const SizedBox(width: MoriSpacing.s3),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: ongoing
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent.withValues(alpha: 0.10),
                              accent.withValues(alpha: 0.02),
                            ],
                          )
                        : null,
                    color: ongoing ? null : context.cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ongoing
                          ? accent.withValues(alpha: 0.5)
                          : mori.borderSo,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetaRow(item: item, ongoing: ongoing),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: context.text.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          height: 1.3,
                          decoration: item.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if ((item.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: context.text.bodySmall?.copyWith(
                            fontSize: 12.5,
                            color: mori.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Agenda item;
  final bool ongoing;
  const _MetaRow({required this.item, required this.ongoing});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final accent = MoriColors.accent;
    return Stack(
      children: [
        Wrap(
          spacing: MoriSpacing.s2,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if ((item.category ?? '').isNotEmpty)
              MTag.category(category: item.category!),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 11, color: mori.dim),
                const SizedBox(width: 4),
                Text(
                  DateId.timeRange(item.startTime, item.endTime),
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 11,
                    color: mori.dim,
                  ),
                ),
              ],
            ),
            if (item.isDone)
              Text(
                '✓ Selesai',
                style: context.text.bodySmall?.copyWith(
                  fontSize: 11,
                  color: mori.ok,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        if (ongoing)
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.25),
                        blurRadius: 0,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'BERLANGSUNG',
                  style: context.text.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
