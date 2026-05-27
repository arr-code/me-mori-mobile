import 'package:intl/intl.dart';

/// Indonesian date and time formatting helpers.
///
/// Conventions:
///   - Long date:  "Senin, 25 Mei 2026"
///   - Short date: "25/05/26"
///   - Time:       "09.00" (period separator, not colon)
///   - Time range: "09.00 – 10.00"
///
/// All helpers convert to local wallclock before formatting. Backend
/// returns ISO timestamps with offsets (e.g. `2026-05-28T10:00:00+07:00`),
/// which `DateTime.parse` resolves to a UTC instant internally. Without
/// `.toLocal()`, callers would render the UTC hour, not the user's WIB
/// hour — hours appear shifted by 7.
class DateId {
  const DateId._();

  static const _locale = 'id_ID';

  static String longDate(DateTime dt) =>
      DateFormat('EEEE, d MMMM y', _locale).format(dt.toLocal());

  static String shortDate(DateTime dt) =>
      DateFormat('dd/MM/yy', _locale).format(dt.toLocal());

  static String time(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  static String timeRange(DateTime start, DateTime end) =>
      '${time(start)} – ${time(end)}';

  static String monthYear(DateTime dt) =>
      DateFormat('MMMM y', _locale).format(dt.toLocal());

  static String weekdayShort(DateTime dt) =>
      DateFormat('EEE', _locale).format(dt.toLocal());

  /// Hero date for the home screen — "Senin, 25 Mei" (no year, matching
  /// the design's `04 Home` artboard).
  static String heroDate(DateTime dt) =>
      DateFormat('EEEE, d MMMM', _locale).format(dt.toLocal());

  /// Human-readable duration for gap rows: "30 menit", "1j 15m", "2 jam".
  /// Floors seconds; expects non-negative input.
  static String durationShort(Duration d) {
    final mins = d.inMinutes;
    if (mins <= 0) return '0 menit';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '$m menit';
    if (m == 0) return h == 1 ? '1 jam' : '$h jam';
    return '${h}j ${m}m';
  }
}
