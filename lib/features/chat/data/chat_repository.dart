import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import 'chat_api.dart';
import 'dto/chat_requests.dart';
import 'models/chat_send_response.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(api: ref.watch(chatApiProvider)),
);

class ChatRepository {
  final ChatApi api;
  ChatRepository({required this.api});

  Future<ChatTurnResponse> send(ChatSendRequest body) =>
      _run(() => api.send(body));

  Future<void> reset() => _run(() => api.reset());

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
