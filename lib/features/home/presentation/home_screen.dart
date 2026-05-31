import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../shared/extensions/date_id.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../../agenda/application/today_agenda_provider.dart';
import '../../agenda/data/models/agenda.dart';
import '../../agenda/presentation/agenda_row.dart';
import '../../agenda/presentation/gap_row.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/auth_state.dart';

/// Phase 3 — Home / Today.
///
/// Renders a single-day timeline composed of agenda cards and gap markers,
/// plus the design's "Tulis ke Mori…" composer pill that pushes the chat
/// screen (Phase 4 placeholder for now).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _gapThresholdMinutes = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedHomeTabProvider);
    final agendaAsync = ref.watch(agendaForTabProvider(tab));
    final user = switch (ref.watch(authControllerProvider)) {
      Authenticated(user: final u) => u,
      _ => null,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _Header(name: user?.name, pictureUrl: user?.pictureUrl, tab: tab),
                const _TabStrip(),
                Expanded(
                  child: RefreshIndicator(
                    color: MoriColors.accent,
                    onRefresh: () async {
                      ref.invalidate(agendaForTabProvider(tab));
                      await ref.read(agendaForTabProvider(tab).future);
                    },
                    child: agendaAsync.when(
                      loading: () => const _LoadingState(),
                      error: (e, _) => _ErrorState(
                        message: '$e'.replaceFirst('AppError(', '').replaceFirst(
                          RegExp(r'\)$'),
                          '',
                        ),
                        onRetry: () =>
                            ref.invalidate(agendaForTabProvider(tab)),
                      ),
                      data: (items) => items.isEmpty
                          ? _EmptyState(tab: tab)
                          : _Timeline(items: items),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: _Composer(onTap: () => context.push('/chat')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final String? name;
  final String? pictureUrl;
  final HomeTab tab;
  const _Header({this.name, this.pictureUrl, required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaAsync = ref.watch(agendaForTabProvider(tab));
    final stats = agendaAsync.maybeWhen(
      data: (items) => _statsLine(items, isCustom: tab == HomeTab.custom),
      orElse: () => null,
    );

    final (:label, :dateLine) = _headerCopy(tab, ref);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(
                    fontSize: 13,
                    color: MoriColors.accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateLine,
                  style: context.text.headlineMedium?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    height: 1,
                  ),
                ),
                if (stats != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    stats,
                    style: context.text.bodySmall?.copyWith(
                      fontSize: 13,
                      color: context.mori.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: MoriSpacing.s3),
          _HeroAvatar(name: name, pictureUrl: pictureUrl),
        ],
      ),
    );
  }

  ({String label, String dateLine}) _headerCopy(HomeTab tab, WidgetRef ref) {
    switch (tab) {
      case HomeTab.today:
        return (label: 'HARI INI', dateLine: DateId.heroDate(DateTime.now()));
      case HomeTab.thisWeek:
        return (label: 'MINGGU INI', dateLine: DateId.monthYear(DateTime.now()));
      case HomeTab.custom:
        final range = ref.read(customDateRangeProvider);
        if (range == null) {
          return (label: 'KOSTUM', dateLine: 'Pilih rentang tanggal');
        }
        final (start, end) = range;
        final labelTxt = DateId.shortDate(start);
        final dateLineTxt = '${DateId.longDate(start)} – ${DateId.shortDate(end)}';
        return (label: labelTxt, dateLine: dateLineTxt);
    }
  }

  static String? _statsLine(List<Agenda> items, {bool isCustom = false}) {
    if (items.isEmpty) return null;
    final gaps = _countGaps(items);
    final parts = ['${items.length} agenda'];
    if (gaps > 0) parts.add('$gaps jeda kosong');
    return parts.join(' · ');
  }

  static int _countGaps(List<Agenda> items) {
    var count = 0;
    for (var i = 1; i < items.length; i++) {
      final prevEnd = items[i - 1].endTime;
      if (prevEnd == null) continue;
      final gap = items[i].startTime.difference(prevEnd);
      if (gap.inMinutes >= HomeScreen._gapThresholdMinutes) count++;
    }
    return count;
  }
}

class _HeroAvatar extends StatelessWidget {
  final String? name;
  final String? pictureUrl;
  const _HeroAvatar({this.name, this.pictureUrl});

  @override
  Widget build(BuildContext context) {
    final initial =
        (name == null || name!.isEmpty) ? '·' : name!.characters.first.toUpperCase();

    return Semantics(
      button: true,
      label: 'Buka profil',
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => GoRouter.of(context).push('/profile'),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [MoriColors.accent, MoriColors.accentSo],
                ),
                image: pictureUrl == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(pictureUrl!),
                        fit: BoxFit.cover,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: MoriColors.accent.withValues(alpha: 0.55),
                    blurRadius: 14,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: pictureUrl != null
                  ? null
                  : Text(
                      initial,
                      style: TextStyle(
                        color: MoriColors.accentFg,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3,
                        fontFamily: context.text.headlineMedium?.fontFamily,
                      ),
                    ),
            ),
            Positioned(
              top: -1,
              right: 3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.mori.warn,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// ── Tab strip ───────────────────────────────────────────────────────────

class _TabStrip extends ConsumerWidget {
  const _TabStrip();

  static const _tabs = <(HomeTab, String)>[
    (HomeTab.today, 'Hari ini'),
    (HomeTab.thisWeek, 'Minggu ini'),
    (HomeTab.custom, 'Kostum'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedHomeTabProvider);
    final customRange = ref.watch(customDateRangeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                if (i != 0) const SizedBox(width: 6),
                _TabChip(
                  tab: _tabs[i].$1,
                  label: _tabs[i].$2,
                  active: _tabs[i].$1 == selected,
                ),
              ],
            ],
          ),
        ),
        if (selected == HomeTab.custom && customRange != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Text(
              _rangeLabel(customRange),
              style: context.text.bodySmall?.copyWith(
                fontSize: 12,
                color: context.mori.muted,
              ),
            ),
          ),
        if (selected != HomeTab.custom)
          const SizedBox(height: 8),
      ],
    );
  }

  static String _rangeLabel((DateTime, DateTime) range) {
    final (start, end) = range;
    final a = DateId.shortDate(start);
    final b = DateId.shortDate(end);
    return '$a – $b';
  }
}

class _TabChip extends ConsumerWidget {
  final HomeTab tab;
  final String label;
  final bool active;

  const _TabChip({
    required this.tab,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mori = context.mori;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: tab == HomeTab.custom
            ? () => _pickDateRange(context, ref)
            : active
                ? null
                : () => ref.read(selectedHomeTabProvider.notifier).state = tab,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? context.cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? mori.border : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? context.cs.onSurface : mori.muted,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
  final now = DateTime.now();
  final initialRange = ref.read(customDateRangeProvider);
  final picked = await showDateRangePicker(
    context: context,
    firstDate: now.subtract(const Duration(days: 365)),
    lastDate: now.add(const Duration(days: 365)),
    initialDateRange: initialRange != null
        ? DateTimeRange(start: initialRange.$1, end: initialRange.$2)
        : DateTimeRange(start: now, end: now),
    locale: const Locale('id', 'ID'),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: MoriColors.accent,
              ),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    ref.read(customDateRangeProvider.notifier).state =
        (picked.start, picked.end);
    ref.read(selectedHomeTabProvider.notifier).state = HomeTab.custom;
  }
}

// ── Timeline (agenda items + gap markers) ───────────────────────────────

class _Timeline extends StatelessWidget {
  final List<Agenda> items;
  const _Timeline({required this.items});

  @override
  Widget build(BuildContext context) {
    final entries = _buildTimelineEntries(
      items,
      gapThresholdMinutes: HomeScreen._gapThresholdMinutes,
    );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 140),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, i) {
        // No gap above date headers — they bring their own breathing room.
        if (i + 1 < entries.length && entries[i + 1] is _DateHeaderEntry) {
          return const SizedBox(height: 16);
        }
        return const SizedBox(height: 6);
      },
      itemBuilder: (_, i) {
        final e = entries[i];
        return switch (e) {
          _AgendaEntry(:final agenda) => AgendaRow(item: agenda),
          _GapEntry(:final from, :final to) => GapRow(from: from, to: to),
          _DateHeaderEntry(:final date) => _DateHeader(date: date),
        };
      },
    );
  }
}

sealed class _TimelineEntry {
  const _TimelineEntry();
}

class _AgendaEntry extends _TimelineEntry {
  final Agenda agenda;
  const _AgendaEntry(this.agenda);
}

class _GapEntry extends _TimelineEntry {
  final DateTime from;
  final DateTime to;
  const _GapEntry(this.from, this.to);
}

class _DateHeaderEntry extends _TimelineEntry {
  final DateTime date;
  const _DateHeaderEntry(this.date);
}

DateTime _dateOnly(DateTime dt) {
  final local = dt.toLocal();
  return DateTime(local.year, local.month, local.day);
}

List<_TimelineEntry> _buildTimelineEntries(
  List<Agenda> items, {
  required int gapThresholdMinutes,
}) {
  final out = <_TimelineEntry>[];
  // Only show per-day headers when the list actually spans multiple
  // dates — keeps the single-day "Hari ini" view as before.
  final dates = items.map((i) => _dateOnly(i.startTime)).toSet();
  final multiDay = dates.length > 1;

  Agenda? prev;
  DateTime? prevDate;
  for (final cur in items) {
    final curDate = _dateOnly(cur.startTime);
    final sameDayAsPrev = prevDate != null && curDate == prevDate;
    if (multiDay && !sameDayAsPrev) {
      out.add(_DateHeaderEntry(curDate));
    }
    final prevEnd = prev?.endTime;
    if (prevEnd != null && sameDayAsPrev) {
      // Gaps only matter within the same calendar day — skip "Kosong
      // · 14 jam" across day boundaries.
      final gap = cur.startTime.difference(prevEnd);
      if (gap.inMinutes >= gapThresholdMinutes) {
        out.add(_GapEntry(prevEnd, cur.startTime));
      }
    }
    out.add(_AgendaEntry(cur));
    prev = cur;
    prevDate = curDate;
  }
  return out;
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final isToday = _dateOnly(DateTime.now()) == _dateOnly(date);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        children: [
          Text(
            DateId.heroDate(date).toUpperCase(),
            style: context.text.labelSmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isToday ? MoriColors.accent : mori.muted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 1, color: mori.borderSo),
          ),
        ],
      ),
    );
  }
}

// ── States ──────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(MoriColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final HomeTab tab;
  const _EmptyState({required this.tab});

  ({String title, String hint}) get _copy {
    switch (tab) {
      case HomeTab.today:
        return (
          title: CopyId.hariKosong,
          hint: 'Tulis ke Mori untuk atur jadwal pertama hari ini.',
        );
      case HomeTab.thisWeek:
        return (
          title: 'Minggu ini lapang.',
          hint: 'Belum ada jadwal untuk minggu ini.',
        );
      case HomeTab.custom:
        return (
          title: 'Tidak ada agenda',
          hint: 'Coba rentang tanggal yang lain.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final copy = _copy;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 96, 28, 140),
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MoriColors.accent.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 24,
              color: MoriColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          copy.title,
          textAlign: TextAlign.center,
          style: context.text.titleLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          copy.hint,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: mori.muted),
        ),
        const SizedBox(height: MoriSpacing.s4),
        Center(
          child: TextButton.icon(
            onPressed: () => GoRouter.of(context).push('/chat'),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Mulai ngobrol'),
            style: TextButton.styleFrom(
              foregroundColor: MoriColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 96, 28, 140),
      children: [
        Icon(Icons.cloud_off_rounded, size: 32, color: mori.muted),
        const SizedBox(height: 12),
        Text(
          message.isEmpty ? CopyId.errNetwork : message,
          textAlign: TextAlign.center,
          style: context.text.bodyLarge,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}

// ── Composer (FAB) ──────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  final VoidCallback onTap;
  const _Composer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        // Wraps both the "Tulis ke Mori…" pill and the gradient chat
        // button — single composite semantic for screen readers.
        child: Semantics(
          button: true,
          label: 'Tulis pesan ke Mori',
          child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.cs.surface,
                border: Border.all(color: mori.border),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Tulis ke Mori…',
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: mori.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment(-0.3, -1),
                  end: Alignment(0.6, 1),
                  colors: [MoriColors.accent, MoriColors.accentSo],
                ),
                boxShadow: [
                  BoxShadow(
                    color: MoriColors.accent.withValues(alpha: 0.55),
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 24,
                color: MoriColors.accentFg,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
