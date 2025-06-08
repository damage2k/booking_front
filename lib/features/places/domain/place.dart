import 'booking.dart';

class Place {
  final int placeId;
  final String placeCode;
  final Booking? booking;
  final bool isLocked;
  final bool hasSchedule;

  Place({
    required this.placeId,
    required this.placeCode,
    required this.booking,
    required this.isLocked,
    required this.hasSchedule,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['placeId'],
      placeCode: json['placeCode'],
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      isLocked: json['isLocked'],
      hasSchedule: json['hasSchedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'placeCode': placeCode,
      'booking': booking?.toJson(),
      'isLocked': isLocked,
      'hasSchedule': hasSchedule,
    };
  }
}
