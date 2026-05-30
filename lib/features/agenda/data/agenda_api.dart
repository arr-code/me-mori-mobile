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

  /// `GET /api/agenda/today` — current day. Server bucketing uses the
  /// user's stored timezone.
  Future<List<Agenda>> getToday() async {
    final res = await _dio.get<List<dynamic>>('/api/agenda/today');
    return _decodeList(res.data);
  }

  /// `GET /api/agenda/week` — Monday → Sunday of the current week.
  Future<List<Agenda>> getWeek() async {
    final res = await _dio.get<List<dynamic>>('/api/agenda/week');
    return _decodeList(res.data);
  }

  /// `GET /api/agenda?date=YYYY-MM-DD` — items on a specific date.
  Future<List<Agenda>> getByDate(DateTime date) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final res = await _dio.get<List<dynamic>>(
      '/api/agenda',
      queryParameters: {'date': fmt.format(date)},
    );
    return _decodeList(res.data);
  }

  /// `POST /api/agenda` — single create. Min body: `title` + `start_time`.
  Future<Agenda> create(CreateAgendaRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/agenda',
      data: body.toJson(),
    );
    return Agenda.fromJson(res.data!);
  }

  /// `POST /api/agenda/batch` — bulk create. Response shape is
  /// `{ "created": [Agenda, ...] }`.
  Future<List<Agenda>> createBatch(List<Map<String, dynamic>> items) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/agenda/batch',
      data: {'items': items},
    );
    return _decodeList(res.data?['created']);
  }

  /// `PATCH /api/agenda/:id` — partial single update.
  Future<Agenda> update(String id, UpdateAgendaRequest body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/agenda/$id',
      data: body.toJson(),
    );
    return Agenda.fromJson(res.data!);
  }

  /// `PATCH /api/agenda/batch` — bulk partial update. Each item carries
  /// `agenda_id` + only the fields that change. Response shape is
  /// `{ "updated": [Agenda, ...] }`.
  Future<List<Agenda>> updateBatch(List<Map<String, dynamic>> items) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/agenda/batch',
      data: {'items': items},
    );
    return _decodeList(res.data?['updated']);
  }

  /// `DELETE /api/agenda/:id` — single delete. Server returns
  /// `{ "deleted": true }` which we ignore.
  Future<void> delete(String id) =>
      _dio.delete<void>('/api/agenda/$id');

  /// `DELETE /api/agenda/batch` — bulk delete. Body uses `ids`, not
  /// `agenda_ids`.
  Future<void> deleteBatch(List<String> ids) async {
    await _dio.delete<void>(
      '/api/agenda/batch',
      data: {'ids': ids},
    );
  }

  /// `PATCH /api/agenda/:id/done` — flip the `is_done` flag on one item.
  Future<Agenda> toggleDone(String id) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/agenda/$id/done',
    );
    return Agenda.fromJson(res.data!);
  }

  List<Agenda> _decodeList(Object? raw) {
    if (raw is! List) return const [];
    return raw.cast<Map<String, dynamic>>().map(Agenda.fromJson).toList();
  }
}
