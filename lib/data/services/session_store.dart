import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _tokenKey = 'auth_token';
  static const _legacyTokenKey = 'auth.token';
  final FlutterSecureStorage _secure = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  Future<String?> readToken() async {
    try {
      final t = await _secure.read(key: _tokenKey);
      if (t != null && t.isNotEmpty) return t;
    } catch (_) {}
    try {
      final p = await SharedPreferences.getInstance();
      final t = p.getString(_tokenKey) ?? p.getString(_legacyTokenKey);
      if (t != null && t.isNotEmpty) {
        try { await _secure.write(key: _tokenKey, value: t); } catch (_) {}
        return t;
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveToken(String token) async {
    try { await _secure.write(key: _tokenKey, value: token); } catch (_) {}
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_tokenKey, token);
    } catch (_) {}
  }

  Future<void> clear() async {
    try { await _secure.delete(key: _tokenKey); } catch (_) {}
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_tokenKey);
      await p.remove(_legacyTokenKey);
    } catch (_) {}
  }
}
