import 'package:json_annotation/json_annotation.dart';

part 'auth_requests.g.dart';

@JsonSerializable(includeIfNull: false, createFactory: false)
class RegisterRequest {
  final String username;
  final String password;
  final String? name;
  final String? timezone;

  const RegisterRequest({
    required this.username,
    required this.password,
    this.name,
    this.timezone,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GoogleAuthRequest {
  @JsonKey(name: 'id_token')
  final String idToken;

  const GoogleAuthRequest({required this.idToken});

  Map<String, dynamic> toJson() => _$GoogleAuthRequestToJson(this);
}
