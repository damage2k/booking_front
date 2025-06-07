import 'package:booking_front/features/auth/presentation/widgets/reset_password_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/types/result.dart';
import '../../../../shared/ui/app_input.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/ui/primary_button.dart';
import '../providers/auth_providers.dart';

class LoginModal extends ConsumerStatefulWidget {
  const LoginModal({super.key});

  @override
  ConsumerState<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends ConsumerState<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool get isFormValid =>
      loginController.text.trim().isNotEmpty &&
          passwordController.text.length >= 6;

  bool isLoading = false;
  String? error;

  Future<void> _handleLogin() async {
    // final isValid = _formKey.currentState?.validate() ?? false;
    // if (!isValid) return;
    //
    // setState(() {
    //   error = null;
    //   isLoading = true;
    // });

    // try {
    //   final login = ref.read(loginUseCaseProvider);
    //   final (token, user) = await login(
    //     loginController.text.trim(),
    //     passwordController.text.trim(),
    //   );
    //   ref.read(authTokenProvider.notifier).state = token;
    //   ref.read(userProvider.notifier).state = user;
    //   await TokenStorage.saveToken(token);
    //   Navigator.of(context).pop();
    // } catch (e) {
    //   setState(() => error = e.toString());
    // } finally {
    //   setState(() => isLoading = false);
    // }
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      error = null;
      isLoading = true;
    });

    final login = ref.read(loginUseCaseProvider);

    final result = await login(
      loginController.text.trim(),
      passwordController.text.trim(),
    );

    switch (result) {
      case Success(:final data):
        final (token, user) = data;
        ref.read(authTokenProvider.notifier).state = token;
        ref.read(userProvider.notifier).state = user;
        await TokenStorage.saveToken(token);
        if (mounted) Navigator.of(context).pop();
        break;

      case Failure(:final message):
        setState(() => error = message);
        break;
    }

    setState(() => isLoading = false);

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
        canPop: false,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth < 500 ? screenWidth * 0.9 : 400,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Войти',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Логин
                    AppInput(
                      label: 'Логин *',
                      controller: loginController,
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Введите логин' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 64),

                    // Пароль
                    AppInput(
                    label: 'Пароль *',
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                    } else if (value.length < 6) {
                    return 'Минимум 6 символов';
                    }
                    return null;
                    },
                    onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 42),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // закрыть LoginModal
                          showDialog(
                            context: context,
                            builder: (_) => const ResetPasswordModal(),
                          );
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0xFF005AA9); // синий
                            }
                            return const Color(0xFF2E3A59); // обычный
                          }),
                        ),
                        child: const Text('Сбросить пароль', style: TextStyle(fontSize: 14)),
                      ),
                    ),


                    PrimaryButton(
                      text: 'Войти',
                      isLoading: isLoading,
                      isEnabled: isFormValid && !isLoading,
                      onPressed: _handleLogin,
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
