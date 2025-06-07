import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String text;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isEnabled ? const Color(0xFF005AA9) : Colors.grey.shade400;
    final cursor = isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden;

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onTap: isEnabled && !isLoading ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
