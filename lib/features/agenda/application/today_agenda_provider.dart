import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/agenda_repository.dart';
import '../data/models/agenda.dart';

/// Which range of agenda the home screen is showing. Drives the tab
/// strip on top + the body list.
enum HomeTab { today, thisWeek, upcoming }

/// Currently selected home tab. Reset to today implicitly on every cold
/// start (StateProvider).
final selectedHomeTabProvider =
    StateProvider<HomeTab>((ref) => HomeTab.today);

/// Today's agenda — kept as a standalone provider because the header
/// stats line ("N agenda · M jeda · K berlangsung") is always anchored
/// to today, regardless of which tab the body is showing.
/// Items come back sorted by [Agenda.startTime] ascending.
final todayAgendaProvider =
    FutureProvider.autoDispose<List<Agenda>>((ref) async {
  return _fetchRange(ref, HomeTab.today);
});

/// Per-tab agenda fetch. Each [HomeTab] maps to a calendar range; the
/// body of the home screen watches the family instance for the selected
/// tab. `ref.invalidate(agendaForTabProvider)` refreshes all tabs at
/// once (used by chat controller after a commit).
final agendaForTabProvider =
    FutureProvider.autoDispose.family<List<Agenda>, HomeTab>((ref, tab) {
  if (tab == HomeTab.today) {
    // Keep a single fetch in flight for today — body + header share it.
    return ref.watch(todayAgendaProvider.future);
  }
  return _fetchRange(ref, tab);
});

Future<List<Agenda>> _fetchRange(Ref ref, HomeTab tab) async {
  final repo = ref.watch(agendaRepositoryProvider);
  final (from, to) = _rangeFor(tab, DateTime.now());
  final items = await repo.fetchRange(from: from, to: to);
  items.sort((a, b) => a.startTime.compareTo(b.startTime));
  return items;
}

/// Ranges (half-open `[from, to)`):
///   today      — today 00:00 .. tomorrow 00:00
///   thisWeek   — Monday this week .. Monday next week  (Mon as ISO start)
///   upcoming   — Monday next week .. +30 days
(DateTime, DateTime) _rangeFor(HomeTab tab, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (tab) {
    case HomeTab.today:
      return (today, today.add(const Duration(days: 1)));
    case HomeTab.thisWeek:
      final mondayThis = today.subtract(Duration(days: today.weekday - 1));
      final mondayNext = mondayThis.add(const Duration(days: 7));
      return (mondayThis, mondayNext);
    case HomeTab.upcoming:
      final mondayThis = today.subtract(Duration(days: today.weekday - 1));
      final mondayNext = mondayThis.add(const Duration(days: 7));
      return (mondayNext, mondayNext.add(const Duration(days: 30)));
  }
}
