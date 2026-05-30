// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Agenda _$AgendaFromJson(Map<String, dynamic> json) => Agenda(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      category: json['category'] as String?,
      isDone: json['is_done'] as bool? ?? false,
      reminderMinutes: (json['reminder_minutes'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
    );

Map<String, dynamic> _$AgendaToJson(Agenda instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'category': instance.category,
      'is_done': instance.isDone,
      'reminder_minutes': instance.reminderMinutes,
      'user_id': instance.userId,
    };
