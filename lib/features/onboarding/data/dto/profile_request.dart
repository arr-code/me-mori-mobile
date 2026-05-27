import 'package:json_annotation/json_annotation.dart';

part 'profile_request.g.dart';

/// Payload for `PATCH /api/users/me/profile`. All fields are optional from
/// the transport's perspective — the server merges what we send (partial
/// update; may be called multiple times). The UI enforces which fields are
/// required at form-validation time (profession, goals, working_pattern).
@JsonSerializable(includeIfNull: false, createFactory: false)
class OnboardingProfileRequest {
  final String? profession;
  final String? goals;
  @JsonKey(name: 'working_pattern')
  final String? workingPattern;
  @JsonKey(name: 'personal_rules')
  final String? personalRules;
  final String? bio;

  const OnboardingProfileRequest({
    this.profession,
    this.goals,
    this.workingPattern,
    this.personalRules,
    this.bio,
  });

  Map<String, dynamic> toJson() => _$OnboardingProfileRequestToJson(this);
}
