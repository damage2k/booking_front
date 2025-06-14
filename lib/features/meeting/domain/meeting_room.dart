class MeetingRoom {
  final int id;
  final String code;

  MeetingRoom({
    required this.id,
    required this.code,
  });

  factory MeetingRoom.fromJson(Map<String, dynamic> json) {
    return MeetingRoom(
      id: json['id'],
      code: json['code'],
    );
  }
}
