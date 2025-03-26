import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? "http://10.0.2.2:3000/api/",
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  ));

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  ApiService() {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: "jwt_token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            print("Unauthorized! Token might be expired.");
            // Handle token expiration (e.g., refresh token or logout)
          }
          return handler.next(e);
        },
      ),
    );
  }

  // GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await dio.get(endpoint, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PATCH request (Partial Update)
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await dio.patch(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      Response response = await dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Error handling function
  dynamic _handleError(DioException e) {
    if (e.response != null) {
      print("Error: ${e.response?.statusCode} - ${e.response?.data}");
      throw e.response?.data["message"];
    } else {
      print("Dio Error: ${e.message}");
      throw Exception("Request failed: ${e.message}");
    }
  }

}
