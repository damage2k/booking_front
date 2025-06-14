import 'package:booking_front/shared/utils/time_input_formatter.dart';
import 'package:flutter/material.dart';

class TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const TimeField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 5,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [TimeInputFormatter()],
      validator: validator,
    );
  }
}
