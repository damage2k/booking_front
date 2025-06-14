import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/date_provider.dart';

class DateToggle extends ConsumerWidget {
  final bool isMobile;

  const DateToggle({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    //final now = DateTime.now().add(Duration(days: 1));
    final now = DateTime.now();


    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 32),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        isSelected: [
          selectedDate.day == now.day &&
              selectedDate.month == now.month &&
              selectedDate.year == now.year,
          selectedDate.day == now.add(const Duration(days: 1)).day &&
              selectedDate.month == now.add(const Duration(days: 1)).month &&
              selectedDate.year == now.add(const Duration(days: 1)).year,
        ],
        onPressed: (index) {
          final newDate = now.add(Duration(days: index));
          ref.read(selectedDateProvider.notifier).state = newDate;
        },
        constraints: BoxConstraints(
          minWidth: isMobile ? 100 : 200,
          minHeight: isMobile ? 40 : 50,
        ),
        children: [
          Text(
            'Сегодня',
            style: TextStyle(fontSize: isMobile ? 14 : 18),
          ),
          Text(
            'Завтра',
            style: TextStyle(fontSize: isMobile ? 14 : 18),
          ),
        ],
      ),
    );
  }
}
