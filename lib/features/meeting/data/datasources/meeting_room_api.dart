import 'package:dio/dio.dart';

import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../../domain/meeting_room.dart';
import '../../domain/meeting_room_booking.dart';
import '../../domain/participant.dart';

class MeetingRoomsApi {
  final Dio _dio = ApiClient.dio;

  // Получение всех переговорных комнат
  Future<Result<List<MeetingRoom>>> getMeetingRooms() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await _dio.get(
        '/api/meeting-rooms',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final rooms = (response.data as List)
          .map((json) => MeetingRoom.fromJson(json))
          .toList();

      return Success(rooms);
    } on DioException catch (e) {
      final message =
          e.response?.data['errorMessage'] ?? 'Ошибка получения переговорных комнат';
      return Failure(message.toString());
    }
  }

  // Получение забронированных переговорных комнат на дату
  Future<Result<List<MeetingRoomBooking>>> getBookedRooms(String date) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await _dio.get(
        '/api/bookings/rooms',
        queryParameters: {'date': date},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final bookings = (response.data as List)
          .map((json) => MeetingRoomBooking.fromJson(json))
          .toList();

      return Success(bookings);
    } on DioException catch (e) {
      final message =
          e.response?.data['errorMessage'] ?? 'Ошибка получения брони по переговорным';
      return Failure(message.toString());
    }
  }

  // Создание брони переговорной комнаты
  Future<Result<MeetingRoomBooking>> createRoomBooking({
    required int meetingRoomId,
    required String date,
    required String startTime,
    required String endTime,
    required String topic,
    required List<Participant> participants,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await _dio.post(
        '/api/bookings/rooms',
        data: {
          'meetingRoomId': meetingRoomId,
          'date': date,
          'startTime': startTime,
          'endTime': endTime,
          'topic': topic,
          'participants': participants.map((p) => p.username).toList(),
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final booking = MeetingRoomBooking.fromJson(response.data);
      return Success(booking);
    } on DioException catch (e) {
      final data = e.response?.data;

      // Формат с violations
      if (data is Map && data['violations'] is List) {
        final messages = (data['violations'] as List)
            .map((v) => v['message'])
            .whereType<String>()
            .join('\n');
        return Failure(messages);
      }

      // Новый формат с errors
      if (data is Map && data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty && errors.first is Map) {
          final errorMessage = errors.first['errorMessage'] ?? 'Неизвестная ошибка';
          return Failure(errorMessage.toString());
        }
      }

      // Старый формат с errorMessage
      if (data is Map && data['errorMessage'] is String) {
        return Failure(data['errorMessage'] as String);
      }

      // fallback
      return Failure(e.message ?? 'Неизвестная ошибка при создании брони');
    }
  }

  // Отмена брони переговорной комнаты
  Future<Result<void>> cancelRoomBooking(int bookingId) async {
    try {
      final token = await TokenStorage.getToken();
      await _dio.delete(
        '/api/bookings/rooms/$bookingId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      return Success(null);
    } on DioException catch (e) {
      final message =
          e.response?.data['errorMessage'] ?? 'Не удалось отменить бронь переговорной';
      return Failure(message.toString());
    }
  }

  // Получение бронирований за период
  Future<Result<List<MeetingRoomBooking>>> getBookingsForRange(
     String startDate,
     String endDate,
  ) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await _dio.get(
        '/api/bookings/rooms/filter',
        queryParameters: {
          'filterStartDate': startDate,
          'filterEndDate': endDate,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final bookings = (response.data as List)
          .map((json) => MeetingRoomBooking.fromJson(json))
          .toList();

      return Success(bookings);
    } on DioException catch (e) {
      final message =
          e.response?.data['errorMessage'] ?? 'Ошибка загрузки бронирований';
      return Failure(message.toString());
    }
  }
}
