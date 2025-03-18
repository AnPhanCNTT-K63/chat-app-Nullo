import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:3000/api/",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  ));

  // GET request
  Future<dynamic> getRequest(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await dio.get(endpoint, queryParameters: queryParams);
      return response.data["data"];
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // POST request
  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await dio.post(endpoint, data: data);
      return response.data["data"];
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PUT request (Update)
  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await dio.put(endpoint, data: data);
      return response.data["data"];
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PATCH request (Partial Update)
  Future<dynamic> patchRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await dio.patch(endpoint, data: data);
      return response.data["data"];
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      Response response = await dio.delete(endpoint);
      return response.data["data"];
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Error handling function
  dynamic _handleError(DioException e) {
    if (e.response != null) {
      print("Error: ${e.response?.statusCode} - ${e.response?.data}");
      return {"error": e.response?.data};
    } else {
      print("Dio Error: ${e.message}");
      return {"error": "Request failed"};
    }
  }
}
