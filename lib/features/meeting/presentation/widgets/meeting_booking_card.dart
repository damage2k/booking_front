import 'package:flutter/material.dart';
import '../../domain/meeting_room_booking.dart';
import 'meeting_booking_details_dialog.dart';

class MeetingBookingCard extends StatelessWidget {
  final MeetingRoomBooking booking;
  final double top;
  final double height;

  const MeetingBookingCard({
    super.key,
    required this.booking,
    required this.top,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final start = booking.startTime.substring(0, 5);
    final end = booking.endTime.substring(0, 5);
    final participants = booking.participants;
    const avatarSize = 24.0;
    const overlap = 12.0;

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => MeetingBookingDetailsDialog(booking: booking),
            );
          },
          child: Container(
            height: height,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$start – $end', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('Комната: ${booking.meetingRoom}', style: const TextStyle(fontSize: 12)),

                const SizedBox(height: 8),
                // Аватары участников
                SizedBox(
                  height: avatarSize,
                  child: Stack(
                    children: [
                      for (int i = 0; i < participants.length && i < 5; i++)
                        Positioned(
                          left: i * overlap,
                          child: CircleAvatar(
                            radius: avatarSize / 2,
                            backgroundColor: Colors.blue.shade800,
                            child: Text(
                              participants[i].lastName[0],
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      if (participants.length > 5)
                        Positioned(
                          left: 5 * overlap,
                          child: CircleAvatar(
                            radius: avatarSize / 2,
                            backgroundColor: Colors.grey.shade700,
                            child: Text(
                              '+${participants.length - 5}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
