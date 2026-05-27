// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      if (instance.name case final value?) 'name': value,
      if (instance.timezone case final value?) 'timezone': value,
    };

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

Map<String, dynamic> _$GoogleAuthRequestToJson(GoogleAuthRequest instance) =>
    <String, dynamic>{
      'id_token': instance.idToken,
    };
