import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

/// Hook the AuthController exposes to the interceptor without creating a
/// circular dependency between the api layer and the feature layer.
final onUnauthorizedProvider = Provider<Future<void> Function()?>((ref) => null);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      storage,
      onUnauthorized: () async {
        final cb = ref.read(onUnauthorizedProvider);
        await cb?.call();
      },
    ),
  );

  return dio;
});
