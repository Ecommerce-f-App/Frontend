
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/secure_store.dart';
import '../models/auth_models.dart';

class AuthService {
  final _api = ApiClient().dio;

  Future<LoginResponse> login(String email, String password) async {
    try {
      final res = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final lr = LoginResponse.fromJson(res.data);
      await SecureStore.saveToken(lr.token);
      return lr;
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg ?? 'No se pudo iniciar sesión');
    }
  }

  Future<LoginResponse> registerClient(String email, String password) async {
    try {
      final res = await _api.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
      final lr = LoginResponse.fromJson(res.data);
      await SecureStore.saveToken(lr.token);
      return lr;
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg ?? 'No se pudo registrar');
    }
  }

  Future<MeResponse> me() async {
    final res = await _api.get('/auth/me');
    return MeResponse.fromJson(res.data);
  }

  Future<void> logout() => SecureStore.clearToken();

  String? _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map && data['message'] is String) return data['message'];
    if (data is Map && data['error'] is String) return data['error'];
    return e.message;
  }
}
