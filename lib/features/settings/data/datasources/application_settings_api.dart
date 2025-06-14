import 'package:dio/dio.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../../domain/application_setting.dart';



class ApplicationSettingsApi {
  final Dio _dio = ApiClient.dio;

  Future<Result<List<ApplicationSetting>>> getSettings() async {
    try {
      final token = await TokenStorage.getToken();

      final res = await _dio.get('/api/application-settings',
          options: Options(headers: {
                'Authorization': 'Bearer $token',
          }));
      final settings = (res.data as List)
          .map((json) => ApplicationSetting.fromJson(json))
          .toList();
      return Success(settings);
    } on DioException catch (e) {
      return Failure(e.message ?? 'Ошибка получения настроек');
    }
  }
}
