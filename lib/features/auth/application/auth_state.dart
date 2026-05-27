import '../data/models/user.dart';

/// Authentication state. `unknown` is the bootstrap state — used while
/// the controller is reading a persisted JWT from secure storage.
sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class Unauthenticated extends AuthState {
  /// Set after a session expires (401) so the signin screen can surface
  /// "Sesi habis, login lagi." Plain logout leaves this null.
  final String? notice;
  const Unauthenticated({this.notice});
}

class Authenticated extends AuthState {
  final User user;
  final String token;
  const Authenticated({required this.user, required this.token});
}
