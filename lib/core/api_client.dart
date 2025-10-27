import 'package:dio/dio.dart';
import '../config/env.dart';
import 'secure_store.dart';

class ApiClient {
  final Dio dio;

  ApiClient._internal(this.dio);

  factory ApiClient() {
    final dio = Dio(BaseOptions(
      baseUrl: Env.apiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStore.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Si 401 → limpia token para forzar login
          if (e.response?.statusCode == 401) {
            await SecureStore.clearToken();
          }
          handler.next(e);
        },
      ),
    );

    return ApiClient._internal(dio);
  }
}
