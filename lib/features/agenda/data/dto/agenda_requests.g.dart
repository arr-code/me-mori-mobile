// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateAgendaRequestToJson(
        CreateAgendaRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      if (instance.description case final value?) 'description': value,
      'start_time': instance.startTime.toIso8601String(),
      if (instance.endTime?.toIso8601String() case final value?)
        'end_time': value,
      if (instance.category case final value?) 'category': value,
    };

Map<String, dynamic> _$UpdateAgendaRequestToJson(
        UpdateAgendaRequest instance) =>
    <String, dynamic>{
      if (instance.title case final value?) 'title': value,
      if (instance.description case final value?) 'description': value,
      if (instance.startTime?.toIso8601String() case final value?)
        'start_time': value,
      if (instance.endTime?.toIso8601String() case final value?)
        'end_time': value,
      if (instance.category case final value?) 'category': value,
      if (instance.isDone case final value?) 'is_done': value,
    };
