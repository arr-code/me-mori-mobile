import 'package:json_annotation/json_annotation.dart';

part 'agenda.g.dart';

@JsonSerializable()
class Agenda {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  final String? category;
  @JsonKey(name: 'is_done')
  final bool isDone;

  const Agenda({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.category,
    this.isDone = false,
  });

  /// True when [endTime] is in the past (relative to [now], default =
  /// current wallclock). Used to grey out / strike through finished items
  /// the user didn't explicitly mark done.
  bool isPast({DateTime? now}) {
    final n = now ?? DateTime.now();
    return endTime.isBefore(n);
  }

  /// True when [now] falls within `[startTime, endTime)` — drives the
  /// "Berlangsung" pill + gradient bg on the card.
  bool isOngoing({DateTime? now}) {
    final n = now ?? DateTime.now();
    return !startTime.isAfter(n) && endTime.isAfter(n);
  }

  Duration get duration => endTime.difference(startTime);

  factory Agenda.fromJson(Map<String, dynamic> json) => _$AgendaFromJson(json);
  Map<String, dynamic> toJson() => _$AgendaToJson(this);
}
