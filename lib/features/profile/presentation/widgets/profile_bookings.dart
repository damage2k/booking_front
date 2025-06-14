import 'package:booking_front/features/meeting/data/datasources/meeting_room_api.dart';
import 'package:booking_front/features/meeting/domain/meeting_room_booking.dart';
import 'package:booking_front/features/places/domain/booking.dart';
import 'package:booking_front/shared/types/result.dart';
import 'package:booking_front/shared/ui/confirm_dialog.dart';
import 'package:booking_front/shared/ui/generic_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../map/presentation/providers/date_provider.dart';
import '../../../places/presentation/providers/place_providers.dart';

class ProfileBookings extends ConsumerStatefulWidget {
  const ProfileBookings({super.key});

  @override
  ConsumerState<ProfileBookings> createState() => _ProfileBookingsState();
}

class _ProfileBookingsState extends ConsumerState<ProfileBookings> {
  Key futureKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final today = ref.watch(selectedDateProvider);
    final tomorrow = today.add(const Duration(days: 1));
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);

    final placesApi = ref.read(placesApiProvider);
    final roomsApi = MeetingRoomsApi();

    final futureData = Future.wait([
      placesApi.getUserBookings(from: today, to: tomorrow, userId: user.id),
      roomsApi.getBookedRooms(todayStr),
      roomsApi.getBookedRooms(tomorrowStr),
    ]);

    return FutureBuilder<List<Object>>(
      key: futureKey,
      future: futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final placeResult = snapshot.data![0] as Result<List<Booking>>;
        final roomTodayResult = snapshot.data![1] as Result<List<MeetingRoomBooking>>;
        final roomTomorrowResult = snapshot.data![2] as Result<List<MeetingRoomBooking>>;

        final placeBookings =
        placeResult is Success<List<Booking>> ? placeResult.data : <Booking>[];
        final roomBookingsToday =
        roomTodayResult is Success<List<MeetingRoomBooking>> ? roomTodayResult.data : <MeetingRoomBooking>[];
        final roomBookingsTomorrow =
        roomTomorrowResult is Success<List<MeetingRoomBooking>> ? roomTomorrowResult.data : <MeetingRoomBooking>[];

        final hasNoBookings = placeBookings.isEmpty &&
            roomBookingsToday.isEmpty &&
            roomBookingsTomorrow.isEmpty;

        if (hasNoBookings) {
          return const Text('Нет активных бронирований.');
        }

        return Column(
          children: [
            ...placeBookings.map((b) => _BookingCard(
              title: b.placeCode,
              subtitle: b.bookingDate == today ? 'Сегодня' : 'Завтра',
              onRemove: () {
                _confirmAndCancel(
                  context,
                  onConfirm: () async {
                    final result = await placesApi.cancelBooking(b.id);
                    _handleResult(result);
                  },
                );
              },
            )),
            ...roomBookingsToday.map((b) => _BookingCard(
              title: b.meetingRoom,
              subtitle:
              'Сегодня ${b.startTime.substring(0, 5)}–${b.endTime.substring(0, 5)} (${b.topic})',
              onRemove: () {
                _confirmAndCancel(
                  context,
                  onConfirm: () async {
                    final result = await roomsApi.cancelRoomBooking(b.id);
                    _handleResult(result);
                  },
                );
              },
            )),
            ...roomBookingsTomorrow.map((b) => _BookingCard(
              title: b.meetingRoom,
              subtitle:
              'Завтра ${b.startTime.substring(0, 5)}–${b.endTime.substring(0, 5)} (${b.topic})',
              onRemove: () {
                _confirmAndCancel(
                  context,
                  onConfirm: () async {
                    final result = await roomsApi.cancelRoomBooking(b.id);
                    _handleResult(result);
                  },
                );
              },
            )),
          ],
        );
      },
    );
  }

  void _confirmAndCancel(BuildContext context, {required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Отмена бронирования',
        message: 'Вы уверены, что хотите отменить бронь?',
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: onConfirm,
      ),
    );
  }

  void _handleResult(Result result) {
    Navigator.of(context).pop(); // close confirm

    switch (result) {
      case Success():
        ref.invalidate(placesForDateProvider);
        setState(() {
          futureKey = UniqueKey(); // 🔄 обновить FutureBuilder
        });
        showDialog(
          context: context,
          builder: (_) => const GenericSuccessDialog(
            title: 'Успешно',
            message: 'Бронирование отменено.',
          ),
        );
        break;
      case Failure(:final message):
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Ошибка'),
            content: Text(message),
          ),
        );
    }
  }
}

class _BookingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  const _BookingCard({
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
