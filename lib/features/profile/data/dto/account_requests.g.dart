// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AccountPatchRequestToJson(
        AccountPatchRequest instance) =>
    <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      if (instance.timezone case final value?) 'timezone': value,
      'hasAtLeastOneField': instance.hasAtLeastOneField,
    };

Map<String, dynamic> _$PersonaPatchRequestToJson(
        PersonaPatchRequest instance) =>
    <String, dynamic>{
      'persona_id': instance.personaId,
    };
