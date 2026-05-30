import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'dto/chat_requests.dart';
import 'models/chat_send_response.dart';
import 'models/chat_turn.dart';

final chatApiProvider =
    Provider<ChatApi>((ref) => ChatApi(ref.watch(dioProvider)));

class ChatApi {
  final Dio _dio;
  ChatApi(this._dio);

  /// `GET /api/chat/turns?limit=N` — load history, oldest-first. Backend
  /// caps `limit` at 200 (default 50).
  Future<List<ChatTurn>> getHistory({int limit = 50}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/chat/turns',
      queryParameters: {'limit': limit},
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ChatTurn.fromJson)
        .toList();
  }

  /// `POST /api/chat` — send one user message. Backend returns the new
  /// turn (Mori `reply`, `intent`, and at most one `pending_action`).
  /// The commit on Setuju does NOT come from the server — Flutter
  /// executes the agenda mutation directly via `/api/agenda*` first,
  /// then calls `/turns/:id/accept` to mark the turn resolved.
  Future<ChatTurnResponse> send(ChatSendRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/chat',
      data: body.toJson(),
    );
    return ChatTurnResponse.fromJson(res.data!);
  }

  /// `POST /api/chat/turns/:id/accept` — mark a turn as accepted.
  /// Caller MUST have already committed the underlying agenda mutation
  /// before invoking this — backend does not perform the agenda action.
  Future<void> acceptTurn(String turnId) async {
    await _dio.post<dynamic>('/api/chat/turns/$turnId/accept');
  }

  /// `POST /api/chat/turns/:id/reject` — mark a turn as rejected. No
  /// agenda mutation is implied either way.
  Future<void> rejectTurn(String turnId) async {
    await _dio.post<dynamic>('/api/chat/turns/$turnId/reject');
  }

  /// `POST /api/chat/turns/:id/seen?status=...` — lifecycle ping after
  /// a turn finishes rendering, so backend doesn't surface it again as
  /// "fresh" on the next reload. `status` defaults to `rendered`;
  /// `unshown` and `dismissed` are also valid per the API contract.
  Future<void> markSeen(String turnId, {String status = 'rendered'}) async {
    await _dio.post<dynamic>(
      '/api/chat/turns/$turnId/seen',
      queryParameters: {'status': status},
    );
  }

  /// `POST /api/chat/reset` — clear the server-side conversation state.
  /// Pairs with the "↻ ulangi" header button.
  Future<void> reset() async {
    await _dio.post<dynamic>('/api/chat/reset');
  }
}
