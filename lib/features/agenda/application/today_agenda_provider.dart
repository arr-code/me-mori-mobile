import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/agenda_repository.dart';
import '../data/models/agenda.dart';

/// Which range of agenda the home screen is showing. Drives the tab
/// strip on top + the body list.
enum HomeTab { today, thisWeek }

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
    // Reuse the dedicated today provider so header + body share a fetch.
    return ref.watch(todayAgendaProvider.future);
  }
  final repo = ref.watch(agendaRepositoryProvider);
  final items = await repo.fetchWeek();
  items.sort((a, b) => a.startTime.compareTo(b.startTime));
  return items;
});
