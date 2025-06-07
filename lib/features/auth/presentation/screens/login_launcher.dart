import 'package:booking_front/features/map/presentation/screens/office_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_initializer.dart';
import '../../../../shared/widgets/app_header.dart';
import '../providers/auth_providers.dart';
import '../widgets/login_modal.dart';
import '../widgets/session_expired_dialog.dart';

class LoginLauncher extends ConsumerStatefulWidget {
  const LoginLauncher({super.key});

  @override
  ConsumerState<LoginLauncher> createState() => _LoginLauncherState();
}

class _LoginLauncherState extends ConsumerState<LoginLauncher> {
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await initializeApp(ref);
      setState(() => initialized = true);

      if (ref.read(authTokenProvider) == null) {
        // токена нет или он истёк — показываем модалку входа
        if (ref.read(sessionExpiredProvider)) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const SessionExpiredDialog(),
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const LoginModal(),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: const [
          AppHeader(), // Верхняя панель
          Expanded(
            child: OfficeMapScreen(),
          ),
        ],
      ),
    );
  }
}

