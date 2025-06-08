import 'dart:io';
import 'package:dio/dio.dart';

class ProfileService {
  final Dio _dio;

  ProfileService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://192.168.1.30:8002/api', 
              headers: {
                'Accept': 'application/json',
                
                // 'Authorization': 'Bearer YOUR_USER_TOKEN',
              },
            ));

  Future<Response> updateProfile({
    required String fullName,
    //required String phone,
    File? profileImage,
  }) async {
    FormData formData = FormData.fromMap({
      'full_name': fullName,
      //'phone': phone,
      if (profileImage != null)
        'profile_image': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
    });

    final response = await _dio.post('/profile/update', data: formData);
    return response;
  }
}
