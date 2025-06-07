import 'package:booking_front/features/auth/presentation/widgets/login_modal.dart';
import 'package:flutter/material.dart';

class PasswordResetSuccessDialog extends StatelessWidget {
  const PasswordResetSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Пароль успешно изменён',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Теперь вы можете войти с новым паролем.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const LoginModal()), // или ResetPasswordModal
                  },

                  child: const Text('Ок'),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
