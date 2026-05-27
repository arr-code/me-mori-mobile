import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import 'agenda_api.dart';
import 'dto/agenda_requests.dart';
import 'models/agenda.dart';

final agendaRepositoryProvider = Provider<AgendaRepository>(
  (ref) => AgendaRepository(api: ref.watch(agendaApiProvider)),
);

class AgendaRepository {
  final AgendaApi api;
  AgendaRepository({required this.api});

  Future<List<Agenda>> fetchRange({
    required DateTime from,
    required DateTime to,
  }) =>
      _run(() => api.getRange(from: from, to: to));

  Future<Agenda> create(CreateAgendaRequest body) =>
      _run(() => api.create(body));

  Future<List<Agenda>> createBatch(List<Map<String, dynamic>> items) =>
      _run(() => api.createBatch(items));

  Future<Agenda> update(String id, UpdateAgendaRequest body) =>
      _run(() => api.update(id, body));

  Future<List<Agenda>> updateBatch(List<Map<String, dynamic>> items) =>
      _run(() => api.updateBatch(items));

  Future<void> delete(String id) => _run(() => api.delete(id));

  Future<void> deleteBatch(List<String> agendaIds) =>
      _run(() => api.deleteBatch(agendaIds));

  Future<Agenda> toggleDone(String id) => _run(() => api.toggleDone(id));

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
