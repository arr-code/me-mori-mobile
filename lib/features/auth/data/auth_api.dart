import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'dto/auth_requests.dart';
import 'models/auth_response.dart';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioProvider)));

class AuthApi {
  final Dio _dio;
  static final _opts = Options(extra: const {'skipAuth': true});

  AuthApi(this._dio);

  Future<AuthResponse> register(RegisterRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: body.toJson(),
      options: _opts,
    );
    return AuthResponse.fromJson(res.data!);
  }

  Future<AuthResponse> login(LoginRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: body.toJson(),
      options: _opts,
    );
    return AuthResponse.fromJson(res.data!);
  }

  Future<AuthResponse> google(GoogleAuthRequest body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/google',
      data: body.toJson(),
      options: _opts,
    );
    return AuthResponse.fromJson(res.data!);
  }
}
