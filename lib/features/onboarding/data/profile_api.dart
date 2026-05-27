import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/models/user.dart';
import 'dto/profile_request.dart';

final profileApiProvider =
    Provider<ProfileApi>((ref) => ProfileApi(ref.watch(dioProvider)));

class ProfileApi {
  final Dio _dio;
  ProfileApi(this._dio);

  /// `PATCH /api/users/me/profile` — partial update. Server merges the
  /// supplied fields and returns the full updated user. Safe to call
  /// multiple times. The auth interceptor injects the Bearer token.
  Future<User> updateProfile(OnboardingProfileRequest body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/users/me/profile',
      data: body.toJson(),
    );
    return User.fromJson(res.data!);
  }

  /// `POST /api/onboarding/complete` — explicitly marks onboarding as
  /// finished after the required profile fields (profession, goals,
  /// working_pattern) are populated. Backend validates and returns 200
  /// without a body — caller should re-fetch the user (or call GET
  /// /api/users/me) to pick up the updated `onboarded_at`.
  Future<void> completeOnboarding() async {
    await _dio.post<void>('/api/onboarding/complete');
  }
}
