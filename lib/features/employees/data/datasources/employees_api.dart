import 'package:dio/dio.dart';

import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../models/employee_model.dart';

class EmployeesApi {
  final Dio _dio = ApiClient.dio;

  Future<Result<List<EmployeeModel>>> getEmployees() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await _dio.get(
        '/api/employees',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final employees = (response.data as List)
          .map((json) => EmployeeModel.fromJson(json))
          .toList();

      return Success(employees);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['errorMessage'] is String) {
        return Failure(data['errorMessage'] as String);
      }

      return Failure(e.message ?? 'Не удалось загрузить сотрудников');
    }
  }

  Future<Result<void>> createEmployee({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    String? middleName,
    int? teamId,
    String? positionId,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      await _dio.post(
        '/api/employees',
        data: {
          "username": username,
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          "middleName": middleName,
          "positionId": positionId,
          "teamId": teamId,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return Success(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['errorMessage'] is String) {
        return Failure(data['errorMessage'] as String);
      }

      return Failure(e.message ?? 'Не удалось создать сотрудника');
    }
  }


}
