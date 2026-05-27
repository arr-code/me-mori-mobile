import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/data/models/user.dart';
import '../../onboarding/data/dto/profile_request.dart';
import '../../onboarding/data/profile_repository.dart';
import '../data/dto/account_requests.dart';
import '../data/users_repository.dart';

/// Editable field identifier — drives which endpoint the controller hits
/// and which field on the User we slot the new value into.
enum ProfileField {
  name,
  timezone,
  profession,
  goals,
  workingPattern,
  personalRules,
  bio,
}

final profileControllerProvider =
    Provider<ProfileController>((ref) => ProfileController(ref));

/// Glue between the profile screen's edit sheets and the underlying
/// users/profile repositories. After any successful update we hand the
/// returned User back to [AuthController] so the cached snapshot + router
/// pick up the change.
class ProfileController {
  final Ref ref;
  ProfileController(this.ref);

  Future<void> updateField(ProfileField field, String? rawValue) async {
    final auth = ref.read(authControllerProvider.notifier);
    final value = rawValue?.trim() ?? '';

    User updated;
    switch (field) {
      case ProfileField.name:
        if (value.isEmpty) throw Exception('Nama tidak boleh kosong.');
        updated = await ref
            .read(usersRepositoryProvider)
            .patchMe(AccountPatchRequest(name: value));
        break;
      case ProfileField.timezone:
        if (value.isEmpty) throw Exception('Zona waktu tidak boleh kosong.');
        updated = await ref
            .read(usersRepositoryProvider)
            .patchMe(AccountPatchRequest(timezone: value));
        break;
      case ProfileField.profession:
      case ProfileField.goals:
      case ProfileField.workingPattern:
        if (value.isEmpty) {
          throw Exception('Field ini wajib diisi — tidak boleh kosong.');
        }
        updated = await ref
            .read(profileRepositoryProvider)
            .updateProfile(_profileRequestFor(field, value));
        break;
      case ProfileField.personalRules:
      case ProfileField.bio:
        updated = await ref
            .read(profileRepositoryProvider)
            .updateProfile(_profileRequestFor(field, value));
        break;
    }
    await auth.updateUser(updated);
  }

  /// Empty string is the explicit "clear this field" signal per backend
  /// PATCH /api/users/me/profile spec. We only translate that for optional
  /// profile fields (rules / bio); required fields use null instead so
  /// the backend doesn't allow clearing them via this path.
  OnboardingProfileRequest _profileRequestFor(ProfileField field, String value) {
    String? optional(String v) => v.isEmpty ? '' : v;
    String? required(String v) => v.isEmpty ? null : v;

    switch (field) {
      case ProfileField.profession:
        return OnboardingProfileRequest(profession: required(value));
      case ProfileField.goals:
        return OnboardingProfileRequest(goals: required(value));
      case ProfileField.workingPattern:
        return OnboardingProfileRequest(workingPattern: required(value));
      case ProfileField.personalRules:
        return OnboardingProfileRequest(personalRules: optional(value));
      case ProfileField.bio:
        return OnboardingProfileRequest(bio: optional(value));
      case ProfileField.name:
      case ProfileField.timezone:
        // Caller routes these to /api/users/me, not /profile.
        throw StateError('Field $field is handled via PATCH /api/users/me');
    }
  }
}
