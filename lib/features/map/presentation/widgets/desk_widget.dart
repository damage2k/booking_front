import 'package:flutter/material.dart';

class DeskWidget extends StatelessWidget {
  final String label;
  final bool reserved;
  final String? bookedBy;

  const DeskWidget({
    super.key,
    required this.label,
    this.reserved = false,
    this.bookedBy,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = bookedBy != null;

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isOccupied
                ? Colors.white
                : reserved
                ? Colors.grey.shade400
                : const Color(0xFF00A58B),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isOccupied ? Colors.grey.shade800 : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (bookedBy != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              bookedBy!,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
