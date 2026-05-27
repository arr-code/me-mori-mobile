import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String? username;
  final String? email;
  @JsonKey(name: 'picture_url')
  final String? pictureUrl;
  @JsonKey(name: 'persona_id')
  final String? personaId;
  final String? timezone;
  @JsonKey(name: 'auth_type')
  final String? authType;
  final String? profession;
  final String? goals;
  @JsonKey(name: 'working_pattern')
  final String? workingPattern;
  @JsonKey(name: 'personal_rules')
  final String? personalRules;
  final String? bio;
  @JsonKey(name: 'onboarded_at')
  final DateTime? onboardedAt;

  const User({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.pictureUrl,
    this.personaId,
    this.timezone,
    this.authType,
    this.profession,
    this.goals,
    this.workingPattern,
    this.personalRules,
    this.bio,
    this.onboardedAt,
  });

  bool get hasCompletedOnboarding =>
      onboardedAt != null ||
      ((profession?.isNotEmpty ?? false) && (goals?.isNotEmpty ?? false));

  /// Backend nests onboarding fields under `profile: { ... }`. We flatten
  /// that into the top level here so the generated decoder sees a single
  /// flat map. Existing top-level keys win over nested ones (defensive
  /// against future schema changes); persisted-cache JSON already lives
  /// flat so the merge is a no-op on the storage roundtrip.
  factory User.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    if (profile is Map) {
      final merged = Map<String, dynamic>.from(json);
      for (final entry in profile.entries) {
        final key = entry.key.toString();
        merged.putIfAbsent(key, () => entry.value);
      }
      return _$UserFromJson(merged);
    }
    return _$UserFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
