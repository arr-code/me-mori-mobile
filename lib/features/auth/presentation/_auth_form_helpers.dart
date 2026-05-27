import 'package:flutter/services.dart';

import '../../../l10n/copy_id.dart';

/// Backend constraint: username is 8–30 chars, [a-z0-9_].
/// We do format validation client-side to give immediate feedback, but the
/// 409 "Username sudah dipakai" check happens server-side only — never poll
/// for availability (see [prompt.MD] §7 anti-patterns).
class AuthValidators {
  const AuthValidators._();

  static final usernameRegex = RegExp(r'^[a-z0-9_]{8,30}$');

  static String? username(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return CopyId.errUsernameInvalid;
    if (!usernameRegex.hasMatch(v)) return CopyId.errUsernameInvalid;
    return null;
  }

  static String? password(String? raw) {
    final v = raw ?? '';
    if (v.length < 8) return CopyId.errPasswordShort;
    return null;
  }

  static final usernameFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[a-z0-9_]'),
  );
}
