import 'dart:io';
import 'package:deep_fake/services/models/response/user.dart';
import 'package:dio/dio.dart';

class FileApiService {
  // For Android Emulator, use 10.0.2.2 instead of 127.0.0.1 to connect to host machine
  static const String defaultBaseUrl = 'http://10.0.2.2:9000';
  final String baseUrl;
  late final Dio _dio;
  String? _token;

  // Define supported media formats
  static const supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'wmv',
    'flv',
    '3gp',
    'webm'
  ];
  static const supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

  FileApiService({String? token, String? customBaseUrl})
      : baseUrl = customBaseUrl ?? defaultBaseUrl {
    _token = token;
    _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'multipart/form-data',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        connectTimeout:
            const Duration(minutes: 10), // Increased for video processing
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 10),
        validateStatus: (status) {
          return status != null && status < 500;
        }));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  bool _isValidMediaFormat(String filePath, bool isVideo) {
    final ext = filePath.split('.').last.toLowerCase();
    return isVideo
        ? supportedVideoFormats.contains(ext)
        : supportedImageFormats.contains(ext);
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
    return predictMedia(file, false);
  }

  Future<Map<String, dynamic>> predictVideo(File file) async {
    return predictMedia(file, true);
  }

  Future<Map<String, dynamic>> predictMedia(File file, bool isVideo) async {
    try {
      // Validate file format
      if (!_isValidMediaFormat(file.path, isVideo)) {
        final supportedFormats =
            isVideo ? supportedVideoFormats : supportedImageFormats;
        throw Exception(
            'Unsupported file format. Supported formats: ${supportedFormats.join(", ")}');
      }

      // Get file size in MB
      final fileSize = await file.length() / (1024 * 1024);
      if (isVideo && fileSize > 100) {
        // 100MB limit for videos
        throw Exception(
            'Video file is too large. Maximum size allowed is 100MB');
      } else if (!isVideo && fileSize > 10) {
        // 10MB limit for images
        throw Exception(
            'Image file is too large. Maximum size allowed is 10MB');
      }

      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'media_type': isVideo ? 'video' : 'image'
      });

      const endpoint = '/predict/';
      print('Sending request to: $baseUrl$endpoint');
      print(
          'File type: ${isVideo ? "video" : "image"}, Size: ${fileSize.toStringAsFixed(2)}MB');

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
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
      } else if (response.statusCode == 400) {
        final errorMessage =
            response.data?['detail'] ?? 'Invalid file format or corrupted file';
        throw Exception(errorMessage);
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception(
              'Connection timeout. ${isVideo ? "Video processing may take longer than expected." : "Please try again."}');
        }
        if (e.type == DioExceptionType.connectionError) {
          throw Exception(
              'Cannot connect to server. Please check your internet connection and try again.');
        }
        if (e.response?.statusCode == 400) {
          final errorMessage = e.response?.data?['detail'] ??
              (isVideo
                  ? 'Invalid video format or corrupted file'
                  : 'Invalid image format or corrupted file');
          throw Exception(errorMessage);
        }
        if (e.response?.statusCode == 500) {
          final errorMessage = e.response?.data?['detail'] ?? 'Server error';
          throw Exception('Server error: $errorMessage');
        }
      }
      print('Error during prediction: $e');
      throw Exception('Failed to analyze media: $e');
    }
  }
}
