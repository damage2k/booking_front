import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/meeting_room_api.dart';
import '../../domain/meeting_room.dart';
import '../../../../shared/types/result.dart';

// Провайдер API для переговорных комнат
final meetingRoomsApiProvider = Provider<MeetingRoomsApi>((ref) {
  return MeetingRoomsApi();
});

// Провайдер для получения списка всех переговорных комнат
final allMeetingRoomsProvider = FutureProvider<List<MeetingRoom>>((ref) async {
  final api = ref.watch(meetingRoomsApiProvider);
  final result = await api.getMeetingRooms();

  return switch (result) {
    Success(data: final rooms) => rooms,
    Failure(message: final msg) => throw Exception(msg),
  };
});
