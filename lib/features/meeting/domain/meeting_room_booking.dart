import '../../auth/data/models/user_model.dart';
import 'participant.dart';

class MeetingRoomBooking {
  final int id;
  final String meetingRoom;
  final UserModel employee;
  final String topic;
  final String date;
  final String startTime;
  final String endTime;
  final List<Participant> participants;

  MeetingRoomBooking({
    required this.id,
    required this.meetingRoom,
    required this.employee,
    required this.topic,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.participants,
  });

  factory MeetingRoomBooking.fromJson(Map<String, dynamic> json) {
    return MeetingRoomBooking(
      id: json['id'],
      meetingRoom: json['meetingRoom'],
      employee: UserModel.fromJson(json['employee']),
      topic: json['topic'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
    );
  }
}
