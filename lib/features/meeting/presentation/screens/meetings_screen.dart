import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/types/result.dart';
import '../../../settings/presentation/providers/application_settings_providers.dart';
import '../../data/datasources/meeting_room_api.dart';
import '../../domain/meeting_room_booking.dart';
import '../widgets/meeting_day_column.dart';
import '../widgets/meeting_header_row.dart';
import '../widgets/week_range_header.dart';

class _MeetingsScreenState extends ConsumerState<MeetingsScreen> {
  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();

  final ScrollController _headerScroll = ScrollController();

  DateTime _weekStart = DateTime(2025, 6, 9); // стартовая неделя

  @override
  void dispose() {
    _horizontalScroll.dispose();
    _verticalScroll.dispose();
    super.dispose();
  }

  void _changeWeek(int offset) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * offset));
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ошибка: $e')),
          data: (settings) {

            final start = _parseTime(settings.get<String>('BOOKING_ROOMS_ALLOWED_START_TIME') ?? '09:00');
            final end = _parseTime(settings.get<String>('BOOKING_ROOMS_ALLOWED_END_TIME') ?? '18:00');
            final step = Duration(minutes: settings.get<int>('BOOKING_ROOMS_ALLOWED_MIN_MEETING_DURATION_MINUTES') ?? 30);
            final timeSlots = _generateTimeSlots(start, end, step);

            final days = List.generate(7, (i) => _weekStart .add(Duration(days: i)));
            final fromStr = DateFormat('yyyy-MM-dd').format(days.first);
            final toStr = DateFormat('yyyy-MM-dd').format(days.last);

            return FutureBuilder<Result<List<MeetingRoomBooking>>>(
              future: MeetingRoomsApi().getBookingsForRange(fromStr, toStr),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final result = snapshot.data!;
                final bookings = result is Success<List<MeetingRoomBooking>> ? result.data : [];

                final bookingsByDate = <String, List<MeetingRoomBooking>>{};
                for (final b in bookings) {
                  bookingsByDate.putIfAbsent(b.date, () => []).add(b);
                }

                final screenWidth = MediaQuery.of(context).size.width;
                final cellWidth = (screenWidth - 60) / 7;
                final computedCellWidth = cellWidth < 200 ? 200.0 : cellWidth;

                // В Column добавляем WeekRangeHeader, заголовки и сетку
                return Column(
                  children: [
                    WeekRangeHeader(
                      startDate: _weekStart,
                      onPrev: () => _changeWeek(-1),
                      onNext: () => _changeWeek(1),
                    ),
                    // Привязан к _horizontalScroll
                    SingleChildScrollView(
                      controller: _headerScroll,
                      scrollDirection: Axis.horizontal,
                      child: MeetingHeaderRow(
                        days: days,
                        cellWidth: computedCellWidth,
                      ),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollUpdateNotification &&
                              notification.metrics.axis == Axis.horizontal) {
                            _headerScroll.jumpTo(notification.metrics.pixels);
                          }
                          return false;
                        },
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _horizontalScroll,
                          child: SingleChildScrollView(
                            controller: _verticalScroll,
                            child: SingleChildScrollView(
                              controller: _horizontalScroll,
                              scrollDirection: Axis.horizontal,
                              child:SizedBox(
                                width: 60 + days.length * computedCellWidth,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Шкала времени
                                    Column(
                                      children: timeSlots.map((t) {
                                        final time = DateTime(0, 0, 0, t.hour, t.minute);
                                        return Container(
                                          width: 60,
                                          height: 64,
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(DateFormat('HH:mm').format(time)),
                                        );
                                      }).toList(),
                                    ),

                                    // Колонки по дням
                                    ...days.map((day) {
                                      final dateStr = DateFormat('yyyy-MM-dd').format(day);
                                      final dayBookings = bookingsByDate[dateStr] ?? [];
                                      return MeetingDayColumn(
                                        timeSlots: timeSlots,
                                        bookings: dayBookings,
                                        cellWidth: computedCellWidth,
                                        day: day,
                                        cellHeight: 64,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )],
                );
              },
            );
          },
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':').map(int.parse).toList();
    return TimeOfDay(hour: parts[0], minute: parts[1]);
  }

  bool _isBefore(TimeOfDay a, TimeOfDay b) {
    return a.hour < b.hour || (a.hour == b.hour && a.minute < b.minute);
  }

  List<TimeOfDay> _generateTimeSlots(TimeOfDay start, TimeOfDay end, Duration step) {
    final result = <TimeOfDay>[];
    var current = TimeOfDay(hour: start.hour, minute: start.minute);
    while (_isBefore(current, end)) {
      result.add(current);
      final next = DateTime(0, 0, 0, current.hour, current.minute).add(step);
      current = TimeOfDay(hour: next.hour, minute: next.minute);
    }
    return result;
  }
}

class MeetingsScreen extends ConsumerStatefulWidget {
  const MeetingsScreen({super.key});

  @override
  ConsumerState<MeetingsScreen> createState() => _MeetingsScreenState();
}
