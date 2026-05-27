import 'package:json_annotation/json_annotation.dart';

part 'account_requests.g.dart';

/// Payload for `PATCH /api/users/me`. Backend requires at least one field
/// — caller is responsible for not constructing this with both fields null
/// (use `hasAtLeastOneField` to guard).
@JsonSerializable(includeIfNull: false, createFactory: false)
class AccountPatchRequest {
  final String? name;
  final String? timezone;

  const AccountPatchRequest({
    this.name,
    this.timezone,
  });

  bool get hasAtLeastOneField => name != null || timezone != null;

  Map<String, dynamic> toJson() => _$AccountPatchRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, createFactory: false)
class PersonaPatchRequest {
  @JsonKey(name: 'persona_id')
  final String personaId;

  const PersonaPatchRequest({required this.personaId});

  Map<String, dynamic> toJson() => _$PersonaPatchRequestToJson(this);
}
