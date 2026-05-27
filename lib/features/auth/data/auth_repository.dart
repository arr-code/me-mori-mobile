import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_api.dart';
import 'dto/auth_requests.dart';
import 'models/auth_response.dart';
import 'models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    api: ref.watch(authApiProvider),
    storage: ref.watch(secureStorageProvider),
  ),
);

class AuthRepository {
  final AuthApi api;
  final SecureStorage storage;

  AuthRepository({required this.api, required this.storage});

  Future<AuthResponse> register(RegisterRequest body) =>
      _run(() => api.register(body));

  Future<AuthResponse> login(LoginRequest body) =>
      _run(() => api.login(body));

  Future<AuthResponse> google(GoogleAuthRequest body) =>
      _run(() => api.google(body));

  Future<String?> readToken() => storage.readToken();

  Future<User?> readCachedUser() async {
    final raw = await storage.readUserJson();
    if (raw == null || raw.isEmpty) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> persistUser(User user) =>
      storage.writeUserJson(jsonEncode(user.toJson()));

  Future<void> clearSession() => storage.clearSession();

  Future<AuthResponse> _run(Future<AuthResponse> Function() call) async {
    try {
      final res = await call();
      await storage.writeToken(res.token);
      await storage.writeUserJson(jsonEncode(res.user.toJson()));
      return res;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
