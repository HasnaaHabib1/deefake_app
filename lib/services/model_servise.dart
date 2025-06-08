import 'dart:io';
import 'package:deep_fake/services/models/response/user.dart';     
import 'package:dio/dio.dart';

class FileApiService {
  final String baseUrl = 'http://192.168.1.30:8002/api'; 
  late final Dio _dio;
  String? _token;

  FileApiService({String? token}) {
    _token = token;
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'multipart/form-data',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
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
}
