import 'package:dio/dio.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../../domain/participant.dart';

class ParticipantsApi {
  final Dio _dio = ApiClient.dio;

  Future<Result<List<Participant>>> searchByLastName(String query) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await _dio.get(
        '/api/employees',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final users = (response.data as List)
          .map((json) => Participant.fromJson(json))
          .where((e) =>
          e.lastName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return Success(users);
    } on DioException catch (e) {
      final message =
          e.response?.data['errorMessage'] ?? 'Ошибка загрузки сотрудников';
      return Failure(message.toString());
    }
  }
}
