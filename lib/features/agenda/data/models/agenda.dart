import 'package:json_annotation/json_annotation.dart';

part 'agenda.g.dart';

@JsonSerializable()
class Agenda {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  // Nullable — backend may not have an end time set (e.g. when user
  // dictates a single time and lets the server default later).
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final String? category;
  @JsonKey(name: 'is_done')
  final bool isDone;
  @JsonKey(name: 'reminder_minutes')
  final int? reminderMinutes;
  @JsonKey(name: 'user_id')
  final String? userId;

  const Agenda({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.category,
    this.isDone = false,
    this.reminderMinutes,
    this.userId,
  });

  /// True when the item's end (or start, if no end set) is in the past
  /// relative to [now]. Used to grey out / strike through finished
  /// items the user didn't explicitly mark done.
  bool isPast({DateTime? now}) {
    final n = now ?? DateTime.now();
    return (endTime ?? startTime).isBefore(n);
  }

  /// True when [now] falls within `[startTime, endTime)`. Items without
  /// an end time are never reported as ongoing.
  bool isOngoing({DateTime? now}) {
    final end = endTime;
    if (end == null) return false;
    final n = now ?? DateTime.now();
    return !startTime.isAfter(n) && end.isAfter(n);
  }

  /// Null when `endTime` is missing.
  Duration? get duration => endTime?.difference(startTime);

  factory Agenda.fromJson(Map<String, dynamic> json) => _$AgendaFromJson(json);
  Map<String, dynamic> toJson() => _$AgendaToJson(this);
}
