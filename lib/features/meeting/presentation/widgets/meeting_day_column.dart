import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/meeting_room_booking.dart';
import 'meeting_booking_card.dart';

class MeetingDayColumn extends StatelessWidget {
  final DateTime day;
  final List<TimeOfDay> timeSlots;
  final List<MeetingRoomBooking> bookings;
  final double cellHeight;
  final double cellWidth;

  const MeetingDayColumn({
    super.key,
    required this.day,
    required this.timeSlots,
    required this.bookings,
    required this.cellHeight,
    required this.cellWidth,
  });

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':').map(int.parse).toList();
    return TimeOfDay(hour: parts[0], minute: parts[1]);
  }

  double _calculateTopOffset(List<TimeOfDay> slots, TimeOfDay time) {
    for (int i = 0; i < slots.length; i++) {
      final t = slots[i];
      if (t.hour == time.hour && t.minute == time.minute) return i * cellHeight;
    }
    return 0;
  }

  double _calculateCardHeight(List<TimeOfDay> slots, TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final durationMinutes = endMinutes - startMinutes;

    final stepMinutes = _slotDurationInMinutes(slots);
    final steps = (durationMinutes / stepMinutes).round() + 1;

    return steps * cellHeight;
  }

  int _slotDurationInMinutes(List<TimeOfDay> slots) {
    if (slots.length < 2) return 30;
    final first = slots[0];
    final second = slots[1];

    final m1 = first.hour * 60 + first.minute;
    final m2 = second.hour * 60 + second.minute;
    return m2 - m1;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);

    return SizedBox(
      width: cellWidth,
      child: SizedBox(
        height: timeSlots.length * cellHeight,
        child: Stack(
          children: [
            // Сетка
            Column(
              children: timeSlots.map((_) {
                return Container(
                  height: cellHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                );
              }).toList(),
            ),

            // Карточки
            ...bookings.where((b) => b.date == dateStr).map((booking) {
              final start = _parseTime(booking.startTime);
              final end = _parseTime(booking.endTime);

              final top = _calculateTopOffset(timeSlots, start);
              final bottom = _calculateTopOffset(timeSlots, end);
              final height = _calculateCardHeight(timeSlots, start, end);

              return MeetingBookingCard(
                booking: booking,
                top: top,
                height: height,
              );
            }),
          ],
        ),
      ),
    );
  }
}
