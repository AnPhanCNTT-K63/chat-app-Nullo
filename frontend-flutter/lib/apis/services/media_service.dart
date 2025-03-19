import 'package:app_chat_nullo/apis/api_service.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class MediaService {
  final _apiService = ApiService();

  Future<void> uploadAvatar(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      String mimeType = 'image/$fileExtension';
      if (fileExtension == 'jpg') {
        mimeType = 'image/jpeg';
      }

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      Response response = await _apiService.dio.post(
        'user/upload-avatar',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print('Upload successful: ${response.data}');
    } on DioException catch (e) {
      print('Upload failed: ${e.response?.data ?? e.message}');
    }
  }
}