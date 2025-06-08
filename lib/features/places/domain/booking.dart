
import '../../auth/data/models/user_model.dart';

class Booking {
  final int id;
  final String bookingDate;
  final UserModel employee;
  final String placeCode;

  Booking({
    required this.id,
    required this.bookingDate,
    required this.employee,
    required this.placeCode,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingDate: json['bookingDate'],
      employee: UserModel.fromJson(json['employee']),
      placeCode: json['placeCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingDate': bookingDate,
      'employee': employee.toJson(),
      'placeCode': placeCode,
    };
  }
}
