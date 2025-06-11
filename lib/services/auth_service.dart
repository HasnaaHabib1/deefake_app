import 'dart:convert';
import 'package:deep_fake/services/models/response/otp_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String baseUrl = 'http://192.168.1.30:8002/api';

  String? _token;
  Map<String, dynamic>? _userData;

  AuthService._internal();

  // getter   
  String? get token => _token;
  Map<String, dynamic>? userData() => _userData;

  // setter
  void setUserData(Map<String, dynamic> data) {
    _userData = data;
  }

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> saveTokenAndUser(String token, Map<String, dynamic> user) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_data', value: jsonEncode(user));
  }

  Future<bool> loadTokenAndUser() async {
    final token = await _storage.read(key: 'auth_token');
    final userStr = await _storage.read(key: 'user_data');

    if (token != null && userStr != null) {
      _token = token;
      _dio.options.headers['Authorization'] = 'Bearer $token';
      try {
        _userData = Map<String, dynamic>.from(jsonDecode(userStr));
      } catch (e) {
        _userData = null;
      }
      return true;
    }
    return false;
  }

  Future<void> clearStorage() async {
    _token = null;
    _userData = null;
    _dio.options.headers.remove('Authorization');
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }

  Future<bool> isFirstTimeUser() async {
    String? isFirstTime = await _storage.read(key: 'is_first_time');

    if (isFirstTime == null) {
      await _storage.write(key: 'is_first_time', value: 'false');
      return true;
    }

    return false;
  }



  Future<bool> validateUserSession() async {
  try {
    final response = await _dio.get(
      '$baseUrl/user',
      options: Options(headers: {
        'Authorization': 'Bearer $_token',
      }),
    );
    return response.statusCode == 200 && response.data['status'] == true;
  } catch (e) {
    return false;
  }
}









  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'full_name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      if (response.data['status'] == true && response.data['token'] != null) {
        final token = response.data['token'];
        setToken(token);
        if (response.data.containsKey('user')) {
          final user = Map<String, dynamic>.from(response.data['user']);
          setUserData(user);
          await saveTokenAndUser(token, user);
        }
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<OtpResponse> sendOtp(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/send-otp',
        data: {'email': email},
      );
      if (response.statusCode == 200) {
        return OtpResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtpAndRegister({
    required String email,
    required String otpCode,
  }) async {
    if (_token == null || _token!.trim().isEmpty) {
      throw Exception('Token is missing, please set token before verifying OTP.');
    }

    try {
      final response = await _dio.post(
        '$baseUrl/verify-otp-and-register',
        data: {
          'email': email,
          'otp_code': otpCode.trim(),
          'token': _token,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        ),
      );

      print(' verifyOtpAndRegister → Status: ${response.statusCode}');
      print(' verifyOtpAndRegister → Response: ${response.data}');

      return response.data;
    } catch (e) {
      if (e is DioException) {
        print(' DioException caught!');
        print(' Status Code: ${e.response?.statusCode}');
        print(' Error Response: ${e.response?.data}');
      } else {
        print(' Unknown error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['status'] == true &&
          response.data['access_token'] != null) {
        final token = response.data['access_token'];
        setToken(token);

        if (response.data.containsKey('user')) {
          final user = Map<String, dynamic>.from(response.data['user']);
          setUserData(user);

          await saveTokenAndUser(token, user);
        }
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmailToken({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/verify',
        data: {
          'email': email,
          'token': token,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyResetOtp({
    required String email,
    required String otpCode,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/verify-otp',
        data: {
          'email': email,
          'otp_code': otpCode.trim(),
        },
      );
      return response.data['status'] == true;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/reset-password',
        data: {
          'email': email,
          'new_password': newPassword,
        },
      );
      return response.data['status'] == true;
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await Dio().post(
        '$baseUrl/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        _userData = null;
        await clearStorage();
        print('Logout successful');
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout error');
    }
  }
}
