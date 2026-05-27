/// Build-time configuration. Override per build with
/// `--dart-define=MORI_API_BASE_URL=https://api.memori.app`.
class Env {
  const Env._();

  static const apiBaseUrl = String.fromEnvironment(
    'MORI_API_BASE_URL',
    defaultValue: 'https://api.memori.app',
  );

  /// Google sign-in client IDs (set when wiring native config).
  static const googleClientId = String.fromEnvironment(
    'MORI_GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const googleServerClientId = String.fromEnvironment(
    'MORI_GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
