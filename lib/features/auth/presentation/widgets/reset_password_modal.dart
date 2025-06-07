import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/types/result.dart';
import '../../../../shared/ui/secondary_button.dart';
import '../providers/auth_providers.dart';
import 'recover_password_modal.dart';
import 'login_modal.dart';

class ResetPasswordModal extends ConsumerStatefulWidget {
  const ResetPasswordModal({super.key});

  @override
  ConsumerState<ResetPasswordModal> createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends ConsumerState<ResetPasswordModal> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? error;
  bool isLoading = false;

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    final api = ref.read(authApiProvider);
    final result = await api.sendResetPasswordEmail(emailController.text.trim());

    switch (result) {
      case Success():
        if (mounted) {
          Navigator.of(context).pop(); // закрываем это окно
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => RecoverPasswordModal(email: emailController.text.trim()),
          );
        }
        break;
      case Failure(:final message):
        setState(() => error = message);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Сброс пароля',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Введите email';
                      if (!value.contains('@')) return 'Некорректный email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(error!, style: const TextStyle(color: Colors.red)),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Назад',
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const LoginModal(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Отправить код'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
