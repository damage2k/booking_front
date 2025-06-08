import 'package:dio/dio.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../../domain/booking.dart';
import '../../domain/place.dart';
import 'package:intl/intl.dart';

class PlacesApi {
  final Dio _dio = ApiClient.dio;

  Future<Result<void>> createBooking(String placeCode) async {
    try {
      final token = await TokenStorage.getToken();

      await _dio.post(
        '/api/places',
        data: {
          'code': placeCode,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return Success(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      String message;

      if (data is Map<String, dynamic> && data['errorMessage'] is String) {
        message = data['errorMessage'];
      } else if (data is String) {
        message = data;
      } else {
        message = 'Ошибка бронирования';
      }

      return Failure(message);
    }
  }

  Future<Result<List<Place>>> getPlacesForDate(DateTime date) async {
    try {
      final token = await TokenStorage.getToken();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _dio.get(
        '/api/places/map',
        queryParameters: {'date': formattedDate},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = (response.data as List)
          .map((json) => Place.fromJson(json))
          .toList();

      return Success(data);
    } on DioException catch (e) {
      final message = e.response?.data['errorMessage'] ?? 'Ошибка загрузки мест';
      return Failure(message.toString());
    }
  }

  Future<Result<void>> bookPlace({
    required int placeId,
    required DateTime date,
  }) async {
    try {
      final token = await TokenStorage.getToken();

      await _dio.post(
        '/api/bookings/places',
        data: {
          'bookingDate': date.toIso8601String().split('T').first,
          'placeId': placeId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Success(null);
    } on DioException catch (e) {
      final data = e.response?.data;

      // Новый формат с массивом errors
      if (data is Map<String, dynamic> && data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty && errors.first is Map) {
          final errorMessage = errors.first['errorMessage'] ?? 'Неизвестная ошибка';
          return Failure(errorMessage.toString());
        }
      }

      // Старый формат с errorMessage
      final message = data['errorMessage'] ?? 'Ошибка при бронировании';
      return Failure(message.toString());
    }
  }

  Future<Result<List<Booking>>> getUserBookings({
    required DateTime from,
    required DateTime to,
    required int userId,
  }) async {
    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.get(
        '/api/bookings/places/stats',
        queryParameters: {
          'from': from.toIso8601String().split('T').first,
          'to': to.toIso8601String().split('T').first,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List data = response.data;
      final bookings = data
          .map((e) => Booking.fromJson(e))
          .where((b) => b.employee.id == userId)
          .toList();

      return Success(bookings);
    } on DioException catch (e) {
      final message = e.response?.data['errorMessage'] ?? 'Ошибка при загрузке бронирований';
      return Failure(message.toString());
    }
  }

  Future<Result<void>> cancelBooking(int bookingId) async {
    try {
      final token = await TokenStorage.getToken();
      await _dio.delete(
        '/api/bookings/places/$bookingId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      return Success(null);
    } on DioException catch (e) {
      final message = e.response?.data['errorMessage'] ?? 'Не удалось отменить бронь';
      return Failure(message.toString());
    }
  }


}
