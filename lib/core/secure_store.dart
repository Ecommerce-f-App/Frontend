import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _jwtKey = 'jwt_token';
  static final _storage = const FlutterSecureStorage();

  static Future<void> saveToken(String token) =>
      _storage.write(key: _jwtKey, value: token);

  static Future<String?> readToken() =>
      _storage.read(key: _jwtKey);

  static Future<void> clearToken() =>
      _storage.delete(key: _jwtKey);
}
