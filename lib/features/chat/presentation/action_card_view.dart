import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../shared/extensions/date_id.dart';
import '../../../shared/widgets/m_button.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../../agenda/data/models/agenda.dart';
import '../data/models/action_card.dart';

typedef ActionDecisionHandler = void Function(ActionDecision);

/// Inline card the assistant proposes inside the chat transcript.
///
/// Shapes:
///   - Single item (non-batch types): one stacked block in the body.
///   - Batch types: each item rendered as its own block, separated by a
///     divider; header strip carries a small `×N` badge.
///   - Pending, no collision: `[Setuju]` primary + `[Batal]` ghost
///   - Pending, with collision: same 2 buttons, plus a warning block
///     listing the conflicting existing agendas. "Ganti" (replace) is
///     hidden until backend exposes a replace primitive.
///   - Resolved: buttons hide, replaced by a status pill. Card fades to
///     70% opacity.
class ActionCardView extends StatelessWidget {
  final PendingAction action;
  final ActionCardStatus status;
  final bool submitting;
  final ActionDecisionHandler? onDecide;

  const ActionCardView({
    super.key,
    required this.action,
    required this.status,
    this.submitting = false,
    this.onDecide,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final resolved = status != ActionCardStatus.pending;
    final hasCollision = action.hasCollision;
    final items = action.effectiveItems;
    // "Ganti" (replace) only makes sense for a single proposed add that
    // collides with an existing agenda we have an id for.
    final canReplace = hasCollision &&
        action.type == ActionType.add &&
        action.collisions.first.id.isNotEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: AnimatedOpacity(
          opacity: resolved ? 0.7 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: context.cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasCollision
                    ? context.cs.error.withValues(alpha: 0.4)
                    : mori.border,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderStrip(
                    type: action.type,
                    hasCollision: hasCollision,
                    batchCount: action.isBatch ? items.length : 1,
                  ),
                  _Body(type: action.type, items: items),
                  if (hasCollision)
                    _CollisionBlock(collisions: action.collisions),
                  _ActionRow(
                    status: status,
                    submitting: submitting,
                    canReplace: canReplace,
                    onDecide: onDecide,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header strip ────────────────────────────────────────────────────────

class _HeaderStrip extends StatelessWidget {
  final ActionType type;
  final bool hasCollision;
  final int batchCount;

  const _HeaderStrip({
    required this.type,
    required this.hasCollision,
    required this.batchCount,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final accent = MoriColors.accent;
    final err = context.cs.error;
    final iconBg = hasCollision
        ? err.withValues(alpha: 0.15)
        : accent.withValues(alpha: 0.13);
    final iconFg = hasCollision ? err : accent;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: mori.borderSo)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(_iconFor(type, hasCollision), size: 13, color: iconFg),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _labelFor(type),
              style: context.text.labelSmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: mori.muted,
                letterSpacing: 0.6,
              ),
            ),
          ),
          if (batchCount > 1)
            Text(
              '×$batchCount',
              style: context.text.labelSmall?.copyWith(
                fontSize: 11,
                color: mori.dim,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconFor(ActionType type, bool collision) {
    if (collision) return Icons.warning_amber_rounded;
    switch (type) {
      case ActionType.add:
      case ActionType.addBatch:
        return Icons.add_rounded;
      case ActionType.update:
      case ActionType.updateBatch:
        return Icons.edit_rounded;
      case ActionType.delete:
      case ActionType.deleteBatch:
        return Icons.delete_outline_rounded;
      case ActionType.toggle:
        return Icons.check_rounded;
    }
  }

  static String _labelFor(ActionType type) {
    switch (type) {
      case ActionType.add:
      case ActionType.addBatch:
        return CopyId.actionIntentAdd;
      case ActionType.update:
      case ActionType.updateBatch:
        return CopyId.actionIntentEdit;
      case ActionType.delete:
      case ActionType.deleteBatch:
        return CopyId.actionIntentDelete;
      case ActionType.toggle:
        return CopyId.actionIntentToggle;
    }
  }
}

// ── Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final ActionType type;
  final List<ActionItem> items;
  const _Body({required this.type, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        child: Text(
          'Tidak ada detail item.',
          style: context.text.bodySmall
              ?.copyWith(color: context.mori.muted, fontStyle: FontStyle.italic),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i != 0)
            Divider(
              color: context.mori.borderSo,
              height: 1,
              thickness: 1,
              indent: 14,
              endIndent: 14,
            ),
          _ItemBlock(item: items[i], type: type),
        ],
      ],
    );
  }
}

class _ItemBlock extends StatelessWidget {
  final ActionItem item;
  final ActionType type;
  const _ItemBlock({required this.item, required this.type});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final title = item.title ?? _fallbackTitle(type);
    final whenString = _formatWhen(item.startTime, item.endTime);
    final hasAgendaId = (item.agendaId ?? '').isNotEmpty;
    final hasDescription = (item.description ?? '').isNotEmpty;
    final showAgendaId = hasAgendaId &&
        type != ActionType.add &&
        type != ActionType.addBatch;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.bodyLarge?.copyWith(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          if (whenString != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 12, color: mori.muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    whenString,
                    style: context.text.bodySmall?.copyWith(
                      fontSize: 12.5,
                      color: mori.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (hasDescription) ...[
            const SizedBox(height: 6),
            Text(
              item.description!,
              style: context.text.bodySmall?.copyWith(
                fontSize: 12.5,
                color: mori.muted,
                height: 1.4,
              ),
            ),
          ],
          if (showAgendaId) ...[
            const SizedBox(height: 6),
            Text(
              '#${_shortId(item.agendaId!)}',
              style: context.text.labelSmall?.copyWith(
                fontSize: 10.5,
                color: mori.dim,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String? _formatWhen(DateTime? start, DateTime? end) {
    if (start == null) return null;
    final long = DateFormat('EEEE, d MMMM', 'id_ID').format(start.toLocal());
    if (end == null) return '$long · ${DateId.time(start)}';
    return '$long · ${DateId.timeRange(start, end)}';
  }

  static String _shortId(String id) =>
      id.length > 8 ? id.substring(0, 8) : id;

  static String _fallbackTitle(ActionType type) {
    switch (type) {
      case ActionType.add:
      case ActionType.addBatch:
        return 'Agenda baru';
      case ActionType.update:
      case ActionType.updateBatch:
        return 'Perubahan agenda';
      case ActionType.delete:
      case ActionType.deleteBatch:
        return 'Agenda dihapus';
      case ActionType.toggle:
        return 'Tandai selesai';
    }
  }
}

// ── Collision block ─────────────────────────────────────────────────────

class _CollisionBlock extends StatelessWidget {
  final List<Agenda> collisions;
  const _CollisionBlock({required this.collisions});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final err = context.cs.error;
    final first = collisions.first;
    final extra = collisions.length - 1;
    final whenString =
        '${DateFormat('EEEE, d MMMM', 'id_ID').format(first.startTime.toLocal())} · '
        '${DateId.timeRange(first.startTime, first.endTime)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: err.withValues(alpha: 0.08),
          border: Border.all(color: err.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 11, color: err),
                const SizedBox(width: 5),
                Text(
                  CopyId.actionCollisionTitle.toUpperCase(),
                  style: context.text.labelSmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: err,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              first.title,
              style: context.text.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              whenString,
              style: context.text.bodySmall?.copyWith(
                fontSize: 12,
                color: mori.muted,
              ),
            ),
            if (extra > 0) ...[
              const SizedBox(height: 4),
              Text(
                '+ $extra agenda lain bentrok',
                style: context.text.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: mori.dim,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Action row ──────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final ActionCardStatus status;
  final bool submitting;
  final bool canReplace;
  final ActionDecisionHandler? onDecide;

  const _ActionRow({
    required this.status,
    required this.submitting,
    required this.canReplace,
    required this.onDecide,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = status != ActionCardStatus.pending;
    final disabled = submitting || onDecide == null;

    if (resolved) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: _StatusPill(status: status),
      );
    }

    final cancelBtn = MButton(
      label: CopyId.batal,
      size: MButtonSize.md,
      variant: MButtonVariant.ghost,
      onPressed: disabled ? null : () => onDecide!(ActionDecision.reject),
    );

    // On a collision a single proposed add can be resolved three ways:
    // keep both ("Tetap tambah"), replace the colliding agenda ("Ganti"),
    // or cancel. Stacked so the labels never overflow on phone widths.
    if (canReplace) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            MButton(
              label: CopyId.tetapTambah,
              size: MButtonSize.md,
              loading: submitting,
              onPressed:
                  disabled ? null : () => onDecide!(ActionDecision.accept),
            ),
            const SizedBox(height: MoriSpacing.s2),
            Row(
              children: [
                Expanded(
                  child: MButton(
                    label: CopyId.ganti,
                    size: MButtonSize.md,
                    variant: MButtonVariant.warn,
                    leadingIcon: Icons.swap_horiz_rounded,
                    onPressed: disabled
                        ? null
                        : () => onDecide!(ActionDecision.replace),
                  ),
                ),
                const SizedBox(width: MoriSpacing.s2),
                Expanded(child: cancelBtn),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: MButton(
              label: CopyId.setuju,
              size: MButtonSize.md,
              leadingIcon: Icons.check_rounded,
              loading: submitting,
              onPressed:
                  disabled ? null : () => onDecide!(ActionDecision.accept),
            ),
          ),
          const SizedBox(width: MoriSpacing.s2),
          Expanded(child: cancelBtn),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final ActionCardStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    late final IconData icon;
    late final Color fg;
    late final Color bg;
    late final String label;

    switch (status) {
      case ActionCardStatus.accepted:
        icon = Icons.check_rounded;
        fg = mori.ok;
        bg = mori.ok.withValues(alpha: 0.12);
        label = CopyId.aksiSelesai;
        break;
      case ActionCardStatus.rejected:
        icon = Icons.close_rounded;
        fg = mori.muted;
        bg = mori.dim.withValues(alpha: 0.10);
        label = CopyId.dibatalkan;
        break;
      case ActionCardStatus.replaced:
        icon = Icons.swap_horiz_rounded;
        fg = MoriColors.accent;
        bg = MoriColors.accent.withValues(alpha: 0.12);
        label = CopyId.diganti;
        break;
      case ActionCardStatus.pending:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
