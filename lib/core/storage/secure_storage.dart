import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

/// Thin wrapper around `flutter_secure_storage` keyed for Me Mori.
class SecureStorage {
  static const _tokenKey = 'mori.jwt';
  static const _userKey = 'mori.user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readUserJson() => _storage.read(key: _userKey);

  Future<void> writeUserJson(String json) =>
      _storage.write(key: _userKey, value: json);

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<void> clearAll() => _storage.deleteAll();
}
