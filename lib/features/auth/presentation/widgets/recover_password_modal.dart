import 'package:booking_front/features/auth/presentation/widgets/password_reset_success_dialog.dart';
import 'package:booking_front/features/auth/presentation/widgets/reset_password_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/types/result.dart';
import '../providers/auth_providers.dart';

class RecoverPasswordModal extends ConsumerStatefulWidget {
  final String email;

  const RecoverPasswordModal({super.key, required this.email});

  @override
  ConsumerState<RecoverPasswordModal> createState() => _RecoverPasswordModalState();
}

class _RecoverPasswordModalState extends ConsumerState<RecoverPasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  String? error;
  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      error = null;
      isLoading = true;
    });

    final api = ref.read(authApiProvider);

    final result = await api.recoverPassword(
      code: _codeController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      repeatPassword: _repeatPasswordController.text.trim(),
    );

    switch (result) {
      case Success():
        if (mounted) {
          Navigator.of(context).pop(); // закрыть RecoverPasswordModal
          showDialog(
            context: context,
            builder: (_) => const PasswordResetSuccessDialog(),
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Text('Восстановление пароля', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Код подтверждения *'),
                  validator: (value) => value == null || value.isEmpty ? 'Введите код' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Новый пароль *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Введите пароль';
                    if (value.length < 6) return 'Минимум 6 символов';
                    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Должна быть хотя бы 1 заглавная буква';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _repeatPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Повторите пароль *'),
                  validator: (value) {
                    if (value != _newPasswordController.text) return 'Пароли не совпадают';
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
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Закрываем recover
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const ResetPasswordModal(), // или ResetPasswordModal
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF005AA9)),
                          foregroundColor: const Color(0xFF005AA9),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('← Назад'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005AA9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text('Сбросить пароль'),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
