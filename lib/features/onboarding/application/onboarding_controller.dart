import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../profile/data/users_repository.dart';
import '../data/dto/profile_request.dart';
import '../data/profile_repository.dart';

final onboardingControllerProvider =
    Provider<OnboardingController>((ref) => OnboardingController(ref));

class OnboardingController {
  final Ref ref;
  OnboardingController(this.ref);

  /// Three-step onboarding finish:
  ///   1. PATCH /api/users/me/profile — set the profile fields
  ///   2. POST /api/onboarding/complete — backend validates required
  ///      fields are populated, flips `onboarded_at`
  ///   3. GET /api/users/me — fresh User with `onboarded_at` populated
  /// The router watches the resulting Authenticated state and forwards
  /// to /home once `user.hasCompletedOnboarding` is true.
  /// Throws [AppError] on any step; UI surfaces it as a banner.
  Future<void> submit({
    required String profession,
    required String goals,
    required String workingPattern,
    String? personalRules,
    String? bio,
  }) async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final usersRepo = ref.read(usersRepositoryProvider);

    await profileRepo.updateProfile(
      OnboardingProfileRequest(
        profession: profession.trim(),
        goals: goals.trim(),
        workingPattern: workingPattern.trim(),
        personalRules: (personalRules == null || personalRules.trim().isEmpty)
            ? null
            : personalRules.trim(),
        bio: (bio == null || bio.trim().isEmpty) ? null : bio.trim(),
      ),
    );
    await profileRepo.completeOnboarding();
    final fresh = await usersRepo.getMe();
    await ref.read(authControllerProvider.notifier).updateUser(fresh);
  }
}
