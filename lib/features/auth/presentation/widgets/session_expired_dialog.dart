import 'package:flutter/material.dart';
import 'login_modal.dart';

class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Сессия окончена'),
      content: const Text('Пожалуйста, авторизуйтесь снова.'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (_) => const LoginModal(),
            );
          },
          child: const Text('Войти'),
        )
      ],
    );
  }
}
