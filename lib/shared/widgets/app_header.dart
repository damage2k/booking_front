import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../features/auth/presentation/widgets/login_modal.dart';
import '../../features/profile/presentation/widgets/profile_modal.dart'; // импорт утилиты

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final isLoggedIn = token != null;

    final user = ref.watch(userProvider);

    final currentMonthYear = DateUtils.getCurrentMonthYearRu();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Text(
            currentMonthYear,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          isLoggedIn
              ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const ProfileModal(),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 20)),
                  const SizedBox(width: 22),
                  Text(
                    '${user?.lastName} ${user?.firstName} ${user?.middleName ?? ''}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
              : TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LoginModal(),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text("Войти"),
          )

        ],
      ),
    );
  }
}
