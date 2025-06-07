import 'package:dio/dio.dart';
import 'package:booking_front/shared/services/api_client.dart';
import '../../../../shared/types/result.dart';
import '../models/user_model.dart';

class AuthApi {
  final Dio _dio = ApiClient.dio;

  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post('/api/auth/token', data: {
        'username': username,
        'password': password,
      });

      return response.data['token'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['errorMessage'] ?? 'Ошибка авторизации');
      } else {
        throw Exception('Произошла ошибка: ${e.message}');
      }
    }
  }

  Future<Result<void>> sendResetPasswordEmail(String email) async {
    try {
      await _dio.post('/api/employees/reset-password', data: {
        'email': email,
      });
      return const Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Failure('Пользователь с таким email не найден');
      }
      return Failure(e.message ?? 'Не удалось отправить письмо');
    }
  }

  Future<Result<void>> recoverPassword({
    required String code,
    required String newPassword,
    required String repeatPassword,
  }) async {
    try {
      await _dio.post('/api/employees/recover-password', data: {
        'verificationCode': code,
        'newPassword': newPassword,
        'repeatNewPassword': repeatPassword,
      });
      return const Success(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data?['violations'] != null) {
        return Failure(data['violations'][0]['message'] ?? 'Ошибка');
      }
      if (data?['errors'] != null) {
        return Failure(data['errors'][0]['errorMessage'] ?? 'Ошибка');
      }
      if (data?['errorMessage'] != null) {
        return Failure(data['errorMessage']);
      }
      return const Failure('Не удалось сбросить пароль');
    }
  }


  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        '/api/employees/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Ошибка получения пользователя: ${e.response?.statusCode}');
    }
  }

}
