import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

/// Injects `Authorization: Bearer <token>` when one is stored. Clears the
/// token (and lets the AuthController react) when the server returns 401.
class AuthInterceptor extends Interceptor {
  final SecureStorage storage;
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor(this.storage, {this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] != true) {
      final token = await storage.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra['skipAuth'] != true) {
      await storage.clearSession();
      await onUnauthorized?.call();
    }
    handler.next(err);
  }
}
