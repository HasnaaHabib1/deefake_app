import 'dart:io';
import 'package:deep_fake/services/models/response/user.dart';
import 'package:dio/dio.dart';

class FileApiService {
  // For Android Emulator, use 10.0.2.2 instead of 127.0.0.1 to connect to host machine
  static const String defaultBaseUrl = 'http://10.0.2.2:9000';
  final String baseUrl;
  late final Dio _dio;
  String? _token;

  FileApiService({String? token, String? customBaseUrl})
      : baseUrl = customBaseUrl ?? defaultBaseUrl {
    _token = token;
    _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'multipart/form-data',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),
        validateStatus: (status) {
          return status != null && status < 500;
        }));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<UserFile> uploadFile(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post('/upload', data: formData);

      if (response.statusCode == 201) {
        return UserFile.fromJson(response.data['file']);
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<List<UserFile>> fetchUserFiles() async {
    try {
      final response = await _dio.get('/files/history');

      if (response.statusCode == 200) {
        List<dynamic> filesJson = response.data['files'];
        return filesJson.map((json) => UserFile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      throw Exception('Failed to load files: $e');
    }
  }

  Future<bool> deleteFile(int fileId) async {
    try {
      final response = await _dio.delete('/files/$fileId');

      if (response.statusCode == 200) {
        return response.data['status'] == true;
      } else {
        throw Exception('Failed to delete file');
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<Map<String, dynamic>> predictImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      print('Sending request to: $baseUrl/predict/');

      final response = await _dio.post(
        '/predict/',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) {
            return status != null && (status < 500 && status != 307);
          },
        ),
      );

      print('Response received: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final result = response.data as Map<String, dynamic>;
          if (result.containsKey('prediction') &&
              result.containsKey('confidence')) {
            print('Prediction result: $result');
            return result;
          } else {
            print(
                'Invalid response format. Missing required fields. Response: $result');
            throw Exception('Server returned invalid data format');
          }
        } else {
          print(
              'Invalid response type. Expected Map, got: ${response.data.runtimeType}');
          throw Exception('Server returned unexpected data format');
        }
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in predictImage:');
      print(e);
      if (e is DioException) {
        if (e.response?.statusCode == 307) {
          print('Received redirect response. Headers: ${e.response?.headers}');
          throw Exception(
              'Server is redirecting the request. Please use the correct endpoint with trailing slash');
        }
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw Exception(
              'Cannot connect to server at $baseUrl - Please check if the server is running');
        }
      }
      rethrow;
    }
  }
}
