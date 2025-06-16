import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../features/auth/presentation/widgets/login_modal.dart';
import '../../features/profile/presentation/widgets/profile_modal.dart';

class AppHeader extends ConsumerWidget {
  final VoidCallback? onBurgerTap;

  const AppHeader({super.key, this.onBurgerTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final isLoggedIn = token != null;
    final user = ref.watch(userProvider);
    final currentMonthYear = DateUtils.getCurrentMonthYearRu();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          padding: EdgeInsets.only(
            left: isMobile ? 16 : 32,
            right: isMobile ? 16 : 32,
            top: isMobile ? 48 : 12,
            bottom: isMobile ? 12 : 12,
          ),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              if (isMobile && onBurgerTap != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: onBurgerTap,
                  ),
                ),
              Text(
                currentMonthYear,
                style: isMobile
                    ? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                    : const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildUserSection(context, ref, isLoggedIn, user, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserSection(BuildContext context, WidgetRef ref, bool isLoggedIn, dynamic user, bool isMobile) {
    if (isLoggedIn) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const ProfileModal(),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 20)),
              SizedBox(width: isMobile ? 12 : 22),
              Flexible(
                child: Text(
                  '${user?.lastName} ${user?.firstName} ${user?.middleName ?? ''}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const LoginModal(),
          );
        },
        icon: const Icon(Icons.login),
        label: const Text("Войти"),
      );
    }
  }
}
