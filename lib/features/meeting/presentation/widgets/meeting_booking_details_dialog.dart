import 'package:flutter/material.dart';
import '../../domain/meeting_room_booking.dart';

class MeetingBookingDetailsDialog extends StatefulWidget {
  final MeetingRoomBooking booking;

  const MeetingBookingDetailsDialog({super.key, required this.booking});

  @override
  State<MeetingBookingDetailsDialog> createState() =>
      _MeetingBookingDetailsDialogState();
}

class _MeetingBookingDetailsDialogState
    extends State<MeetingBookingDetailsDialog> {
  bool showFullList = false;

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 480,
          minWidth: 280,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.topic,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Время
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 8),
                  Text('${booking.startTime.substring(0, 5)} – ${booking.endTime.substring(0, 5)}'),
                ],
              ),

              const SizedBox(height: 24),

              // Участники (аватары)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: Stack(
                        children: [
                          for (int i = 0; i < booking.participants.length && i < 5; i++)
                            Positioned(
                              left: i * 24.0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue.shade800,
                                child: Text(
                                  booking.participants[i].lastName[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          if (booking.participants.length > 5)
                            Positioned(
                              left: 5 * 24.0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey.shade700,
                                child: Text(
                                  '+${booking.participants.length - 5}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(showFullList
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    onPressed: () =>
                        setState(() => showFullList = !showFullList),
                  ),
                ],
              ),

              if (showFullList) ...[
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: booking.participants.length,
                    itemBuilder: (_, index) {
                      final p = booking.participants[index];
                      final fullName =
                          '${p.lastName} ${p.firstName}${p.middleName != null ? ' ${p.middleName}' : ''}';
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue.shade800,
                          child: Text(
                            p.lastName[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(fullName, style: const TextStyle(fontSize: 14)),
                      );
                    },
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
