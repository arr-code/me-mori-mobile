import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/agenda_repository.dart';
import '../data/models/agenda.dart';

/// Which range of agenda the home screen is showing. Drives the tab
/// strip on top + the body list.
enum HomeTab { today, thisWeek, custom }

/// Currently selected home tab. Reset to today implicitly on every cold
/// start (StateProvider).
final selectedHomeTabProvider =
    StateProvider<HomeTab>((ref) => HomeTab.today);

/// The user's custom date range selection for the "Kostum" tab.
/// `null` means no range has been picked yet.
final customDateRangeProvider =
    StateProvider<(DateTime, DateTime)?>((ref) => null);

/// Today's agenda — kept as a standalone provider because the header
/// stats line ("N agenda · M jeda · K berlangsung") is always anchored
/// to today, regardless of which tab the body is showing.
/// Items come back sorted by [Agenda.startTime] ascending.
final todayAgendaProvider =
    FutureProvider.autoDispose<List<Agenda>>((ref) async {
  final repo = ref.watch(agendaRepositoryProvider);
  final items = await repo.fetchToday();
  items.sort((a, b) => a.startTime.compareTo(b.startTime));
  return items;
});

/// Per-tab agenda fetch. `ref.invalidate(agendaForTabProvider)` refreshes
/// all tabs at once (used by chat controller after a commit).
final agendaForTabProvider =
    FutureProvider.autoDispose.family<List<Agenda>, HomeTab>((ref, tab) async {
  if (tab == HomeTab.today) {
    return ref.watch(todayAgendaProvider.future);
  }
  final repo = ref.watch(agendaRepositoryProvider);
  final List<Agenda> items;
  switch (tab) {
    case HomeTab.thisWeek:
      items = await repo.fetchWeek();
    case HomeTab.custom:
      items = await _fetchCustomRange(ref, repo);
    case HomeTab.today:
      items = const [];
  }
  items.sort((a, b) => a.startTime.compareTo(b.startTime));
  return items;
});

Future<List<Agenda>> _fetchCustomRange(Ref ref, AgendaRepository repo) async {
  final range = ref.watch(customDateRangeProvider);
  if (range == null) return [];
  final (start, end) = range;
  return repo.fetchByRange(start, end);
}
