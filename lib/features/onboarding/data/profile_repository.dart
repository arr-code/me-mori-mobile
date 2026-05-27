import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_error.dart';
import '../../auth/data/models/user.dart';
import 'dto/profile_request.dart';
import 'profile_api.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(api: ref.watch(profileApiProvider)),
);

class ProfileRepository {
  final ProfileApi api;
  ProfileRepository({required this.api});

  Future<User> updateProfile(OnboardingProfileRequest body) async {
    try {
      return await api.updateProfile(body);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await api.completeOnboarding();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
