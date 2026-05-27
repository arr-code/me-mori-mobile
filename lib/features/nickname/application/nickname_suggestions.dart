/// Parse a formal full name into nickname suggestions in the order
/// Mori prefers them on the design's chip row:
///   "Ahmad Surya Wijaya" → ["Surya", "Ahmad", "Ahmad W."]
///   "Aru"                → ["Aru"]
///   "Sri Lestari"        → ["Lestari", "Sri"]
///
/// Mirrors the JS reference (`nickname.jsx::suggestNicknames`):
///   - middle/given name first (parts[1]) when length ≥ 2
///   - first part (parts[0])
///   - first + last initial when length ≥ 2
///
/// Returns deduplicated, preserves order.
List<String> suggestNicknames(String? fullName) {
  final parts = (fullName ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return const [];
  if (parts.length == 1) return [parts.first];

  final out = <String>[
    parts[1],
    parts[0],
    '${parts[0]} ${parts.last.substring(0, 1)}.',
  ];
  final seen = <String>{};
  return out.where((s) => seen.add(s)).toList();
}
