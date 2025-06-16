import 'package:dio/dio.dart';

import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../models/team_model.dart';

class TeamsApi {
  final Dio _dio = ApiClient.dio;

  Future<Result<List<TeamModel>>> getTeams() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await _dio.get(
        '/api/teams',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final teams = (response.data as List)
          .map((json) => TeamModel.fromJson(json))
          .toList();

      return Success(teams);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['errorMessage'] is String) {
        return Failure(data['errorMessage'] as String);
      }

      return Failure(e.message ?? 'Не удалось загрузить команды');
    }
  }
}
