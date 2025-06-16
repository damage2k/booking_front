import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetingHeaderRow extends StatelessWidget {
  final List<DateTime> days;
  final double cellWidth;

  const MeetingHeaderRow({
    super.key,
    required this.days,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox(
        height: 80, // фиксируем высоту
        child: Row(
          children: [
            const SizedBox(width: 68), // под шкалу времени
            ...days.map((date) {

              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

              return SizedBox(
                width: cellWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d MMM', 'ru').format(date),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? Colors.white
                            : isWeekend
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM', 'ru').format(date),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isWeekend ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
