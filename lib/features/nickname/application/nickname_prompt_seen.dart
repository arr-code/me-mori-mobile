import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transient flag: has the current Authenticated session passed the
/// nickname prompt yet? Used by the router to decide between `/nickname`
/// (not seen) and `/onboarding` (seen).
///
/// Intentionally in-memory only — if the user kills the app on `/nickname`
/// they'll see it again on next launch. That's an acceptable trade-off
/// (one extra "Lewati" tap) versus the complexity of per-user persistence.
/// Reset on logout.
final nicknamePromptSeenProvider = StateProvider<bool>((ref) => false);
