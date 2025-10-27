import 'package:dio/dio.dart';
import '../config/env.dart';
import 'secure_store.dart';

class ApiClient {
  final Dio dio;

  ApiClient._internal(this.dio);

  factory ApiClient() {
    final dio = Dio(BaseOptions(
      baseUrl: Env.apiBase,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStore.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // log request
          // print('➡️ ${options.method} ${options.baseUrl}${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // print('✅ ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (e, handler) async {
          // print('❌ ERROR ${e.response?.statusCode} ${e.requestOptions.path} ${e.message}');
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
