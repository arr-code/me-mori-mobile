import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'dto/chat_requests.dart';
import 'models/chat_send_response.dart';

final chatApiProvider =
    Provider<ChatApi>((ref) => ChatApi(ref.watch(dioProvider)));

class ChatApi {
  final Dio _dio;
  ChatApi(this._dio);

  /// `POST /api/chat` — send one user message. Backend returns a single
  /// turn (Mori `reply`, classified `intent`, and at most one
  /// `pending_action` to confirm). The commit on Setuju does NOT go via
  /// `/chat/turns/:id/accept` — the chat controller dispatches directly
  /// to the matching `/api/agenda*` endpoint per `pending_action.type`.
  Future<ChatTurnResponse> send(ChatSendRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/chat',
      data: body.toJson(),
    );
    return ChatTurnResponse.fromJson(res.data!);
  }

  /// `POST /api/chat/reset` — clear the server-side conversation state.
  /// Pairs with the "↻ ulangi" header button.
  Future<void> reset() async {
    await _dio.post<dynamic>('/api/chat/reset');
  }
}
