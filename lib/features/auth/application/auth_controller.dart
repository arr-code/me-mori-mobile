import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/env.dart';
import '../../../core/error/app_error.dart';
import '../../../l10n/copy_id.dart';
import '../../nickname/application/nickname_prompt_seen.dart';
import '../../profile/data/users_repository.dart';
import '../data/auth_repository.dart';
import '../data/dto/auth_requests.dart';
import '../data/models/user.dart';
import 'auth_state.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    clientId: Env.googleClientId.isEmpty ? null : Env.googleClientId,
    serverClientId:
        Env.googleServerClientId.isEmpty ? null : Env.googleServerClientId,
    scopes: const ['email', 'profile', 'openid'],
  );
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Indonesian timezone string — best-effort. Falls back to "Asia/Jakarta"
/// since the app is targeted at Indonesian users.
String _resolveTimezone() {
  try {
    final name = DateTime.now().timeZoneName;
    if (name.isEmpty) return 'Asia/Jakarta';
    return name;
  } catch (_) {
    return 'Asia/Jakarta';
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _bootstrap();
    return const AuthUnknown();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  GoogleSignIn get _google => ref.read(googleSignInProvider);

  /// Minimum on-screen time for the Crest splash so the intro animation
  /// has room to breathe. Runs in parallel with the auth check; the
  /// resolved state is published once *both* complete.
  static const _minSplashDuration = Duration(seconds: 5);

  Future<void> _bootstrap() async {
    final splashTimer = Future<void>.delayed(_minSplashDuration);
    final token = await _repo.readToken();

    if (token == null || token.isEmpty) {
      await splashTimer;
      state = const Unauthenticated();
      return;
    }
    final cached = await _repo.readCachedUser();
    if (cached == null) {
      await _repo.clearSession();
      await splashTimer;
      state = const Unauthenticated();
      return;
    }
    await splashTimer;
    state = Authenticated(user: cached, token: token);
    // Refresh from /api/users/me in the background so stale cached
    // users (e.g. saved before a schema/decoder fix) get reconciled.
    // Failures are swallowed — the cached user stays valid.
    unawaited(_refreshUserSilently());
  }

  Future<void> _refreshUserSilently() async {
    try {
      final fresh = await ref.read(usersRepositoryProvider).getMe();
      await updateUser(fresh);
    } catch (e, st) {
      if (kDebugMode) debugPrint('Silent /me refresh failed: $e\n$st');
    }
  }

  Future<void> register({
    required String username,
    required String password,
    String? name,
  }) async {
    final res = await _repo.register(
      RegisterRequest(
        username: username,
        password: password,
        name: name?.isEmpty == true ? null : name,
        timezone: _resolveTimezone(),
      ),
    );
    state = Authenticated(user: res.user, token: res.token);
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _repo.login(
        LoginRequest(username: username, password: password),
      );
      state = Authenticated(user: res.user, token: res.token);
    } on UnauthorizedError {
      // Anti-enumeration: always surface the same message regardless of which
      // half of the credentials failed. See [prompt.MD] §5.1 critical UX.
      throw const UnauthorizedError(CopyId.errCreds);
    }
  }

  /// Drives the native Google sign-in sheet, then exchanges the id_token
  /// with the backend. Returns true when the user finishes; false when they
  /// cancel the sheet (no error surface needed for cancel).
  ///
  /// Failures here all surface as "Koneksi bermasalah" at the UI today —
  /// the kDebugMode prints below distinguish them in the log:
  ///   - idToken null → Google native sheet returned no token (likely
  ///     missing/wrong `serverClientId` or SHA-1 not registered)
  ///   - DioException → backend /api/auth/google rejected or wrong shape
  ///   - other Exception → JSON decoding of the auth response failed
  Future<bool> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) return false;
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'GoogleSignIn: idToken null. Check Cloud Console: Web client '
            'ID == MORI_GOOGLE_SERVER_CLIENT_ID? Android client SHA-1 + '
            'package name (io.noia.me_mori) registered?',
          );
        }
        throw const UnknownError(CopyId.errNetwork);
      }
      final res = await _repo.google(GoogleAuthRequest(idToken: idToken));
      state = Authenticated(user: res.user, token: res.token);
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('GoogleSignIn failed: $e\n$st');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (await _google.isSignedIn()) {
        await _google.signOut();
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('Google signOut error: $e\n$st');
    }
    await _repo.clearSession();
    // Reset the transient nickname-prompt flag so the next account that
    // signs in on this device sees the prompt again.
    ref.read(nicknamePromptSeenProvider.notifier).state = false;
    state = const Unauthenticated();
  }

  /// Replace the cached user (e.g. after onboarding PATCH /api/users/me/profile).
  Future<void> updateUser(User user) async {
    final current = state;
    if (current is! Authenticated) return;
    await _repo.persistUser(user);
    state = Authenticated(user: user, token: current.token);
  }
}
