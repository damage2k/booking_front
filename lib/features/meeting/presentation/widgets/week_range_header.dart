import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekRangeHeader extends StatelessWidget {
  final DateTime startDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const WeekRangeHeader({
    super.key,
    required this.startDate,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final endDate = startDate.add(const Duration(days: 6));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${DateFormat('d MMM', 'ru').format(startDate)} – ${DateFormat('d MMM', 'ru').format(endDate)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );

  }
}
