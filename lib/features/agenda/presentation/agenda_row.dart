import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../shared/extensions/date_id.dart';
import '../../../shared/widgets/m_tag.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../application/today_agenda_provider.dart';
import '../data/agenda_repository.dart';
import '../data/models/agenda.dart';

class AgendaRow extends ConsumerWidget {
  final Agenda item;
  final VoidCallback? onTap;

  const AgendaRow({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mori = context.mori;
    final now = DateTime.now();
    final ongoing = item.isOngoing(now: now);
    final past = item.isPast(now: now);
    final dimmed = item.isDone || past;
    final accent = MoriColors.accent;

    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.34,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2CB67D),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: InkWell(
                onTap: () => _markDone(context, ref),
                child: Center(
                  child: Icon(
                    item.isDone
                        ? Icons.undo_rounded
                        : Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE53170),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: InkWell(
                onTap: () => _delete(context, ref),
                child: Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 13, 0, 0),
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
            const SizedBox(width: MoriSpacing.s4),
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
      ),
    );
  }

  Future<void> _markDone(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(agendaRepositoryProvider);
    await repo.toggleDone(item.id);
    _invalidateAgenda(ref);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus agenda?'),
        content: Text('"${item.title}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53170)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(agendaRepositoryProvider);
    await repo.delete(item.id);
    _invalidateAgenda(ref);
  }

  static void _invalidateAgenda(WidgetRef ref) {
    ref.invalidate(todayAgendaProvider);
    ref.invalidate(agendaForTabProvider(HomeTab.today));
    ref.invalidate(agendaForTabProvider(HomeTab.thisWeek));
    ref.invalidate(agendaForTabProvider(HomeTab.custom));
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
