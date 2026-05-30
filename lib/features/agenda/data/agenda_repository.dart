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

  Future<List<Agenda>> fetchToday() => _run(() => api.getToday());

  Future<List<Agenda>> fetchWeek() => _run(() => api.getWeek());

  Future<List<Agenda>> fetchByDate(DateTime date) =>
      _run(() => api.getByDate(date));

  Future<Agenda> create(CreateAgendaRequest body) =>
      _run(() => api.create(body));

  Future<List<Agenda>> createBatch(List<Map<String, dynamic>> items) =>
      _run(() => api.createBatch(items));

  Future<Agenda> update(String id, UpdateAgendaRequest body) =>
      _run(() => api.update(id, body));

  Future<List<Agenda>> updateBatch(List<Map<String, dynamic>> items) =>
      _run(() => api.updateBatch(items));

  Future<void> delete(String id) => _run(() => api.delete(id));

  Future<void> deleteBatch(List<String> ids) =>
      _run(() => api.deleteBatch(ids));

  Future<Agenda> toggleDone(String id) => _run(() => api.toggleDone(id));

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
