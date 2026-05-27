import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import 'dto/agenda_requests.dart';
import 'models/agenda.dart';

final agendaApiProvider =
    Provider<AgendaApi>((ref) => AgendaApi(ref.watch(dioProvider)));

class AgendaApi {
  final Dio _dio;
  AgendaApi(this._dio);

  /// `GET /api/agenda?from=YYYY-MM-DD&to=YYYY-MM-DD`. Returns the agenda
  /// items whose `start_time` falls within the inclusive range. Server
  /// is expected to use the user's stored timezone when bucketing.
  Future<List<Agenda>> getRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final res = await _dio.get<List<dynamic>>(
      '/api/agenda',
      queryParameters: {
        'from': fmt.format(from),
        'to': fmt.format(to),
      },
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Agenda.fromJson)
        .toList();
  }

  /// `POST /api/agenda` — single-item create.
  Future<Agenda> create(CreateAgendaRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/agenda',
      data: body.toJson(),
    );
    return Agenda.fromJson(res.data!);
  }

  /// `POST /api/agenda/batch` — bulk create. `items` are passed through
  /// in whatever shape the chat action handed us (typically with
  /// `title`/`start_time`/`end_time`/`description`); backend handles
  /// field normalisation.
  Future<List<Agenda>> createBatch(List<Map<String, dynamic>> items) async {
    final res = await _dio.post<List<dynamic>>(
      '/api/agenda/batch',
      data: {'items': items},
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Agenda.fromJson)
        .toList();
  }

  /// `PATCH /api/agenda/:id` — partial update of one item.
  Future<Agenda> update(String id, UpdateAgendaRequest body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/agenda/$id',
      data: body.toJson(),
    );
    return Agenda.fromJson(res.data!);
  }

  /// `PATCH /api/agenda/batch` — bulk partial update. Each item carries
  /// `agenda_id` + only the fields that change.
  Future<List<Agenda>> updateBatch(List<Map<String, dynamic>> items) async {
    final res = await _dio.patch<List<dynamic>>(
      '/api/agenda/batch',
      data: {'items': items},
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Agenda.fromJson)
        .toList();
  }

  /// `DELETE /api/agenda/:id` — single delete.
  Future<void> delete(String id) =>
      _dio.delete<void>('/api/agenda/$id');

  /// `DELETE /api/agenda/batch` — bulk delete. Body sends `agenda_ids`
  /// array; adjust here if the backend expects a different shape.
  Future<void> deleteBatch(List<String> agendaIds) async {
    await _dio.delete<void>(
      '/api/agenda/batch',
      data: {'agenda_ids': agendaIds},
    );
  }

  /// `PATCH /api/agenda/:id/done` — flip the `is_done` flag on one item.
  /// Sent without a body — the backend toggles the current state.
  Future<Agenda> toggleDone(String id) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/agenda/$id/done',
    );
    return Agenda.fromJson(res.data!);
  }
}
