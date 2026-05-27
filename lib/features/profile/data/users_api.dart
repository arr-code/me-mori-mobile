import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/models/user.dart';
import 'dto/account_requests.dart';

final usersApiProvider =
    Provider<UsersApi>((ref) => UsersApi(ref.watch(dioProvider)));

class UsersApi {
  final Dio _dio;
  UsersApi(this._dio);

  /// `GET /api/users/me` — fresh User snapshot. Useful after side-effects
  /// like `/api/onboarding/complete` where the response is just success.
  Future<User> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/users/me');
    return User.fromJson(res.data!);
  }

  /// `PATCH /api/users/me` — update name and/or timezone. Backend requires
  /// at least one field (caller enforces via [AccountPatchRequest.hasAtLeastOneField]).
  Future<User> patchMe(AccountPatchRequest body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/users/me',
      data: body.toJson(),
    );
    return User.fromJson(res.data!);
  }

  /// `PATCH /api/users/me/persona` — set the assistant persona. Backend
  /// returns the full updated user.
  Future<User> patchPersona(PersonaPatchRequest body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/users/me/persona',
      data: body.toJson(),
    );
    return User.fromJson(res.data!);
  }
}
