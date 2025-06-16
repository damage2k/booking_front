import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class SideNav extends ConsumerWidget {
  final int selectedIndex;
  final void Function(int) onItemSelected;

  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isAdmin = user?.roles.contains('ROLE_ADMIN') ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final items = [
      _NavItem(icon: Icons.map, label: 'Карта офиса'),
      _NavItem(icon: Icons.calendar_today, label: 'Совещания'),
      if (isAdmin) _NavItem(icon: Icons.people, label: 'Сотрудники'),
      _NavItem(icon: Icons.insert_drive_file, label: 'Отчёты'),
      if (isAdmin) _NavItem(icon: Icons.settings, label: 'Настройки'),
    ];

    if (isMobile) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = selectedIndex == index;

            return InkWell(
              onTap: () => onItemSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(item.icon,
                        color: isActive ? Colors.blue : Colors.black,
                        size: 28),
                    const SizedBox(width: 16),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.blue : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    }

    // Desktop: vertical icons, larger and positioned lower
    return Container(
      width: 80,
      padding: const EdgeInsets.only(top: 80), // отступ сверху как будто под логотип
      decoration: const BoxDecoration(color: Color(0xFFF4F6FA)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: IconButton(
              tooltip: item.label,
              icon: Icon(
                item.icon,
                color: isActive ? Colors.blue : Colors.black,
                size: 32, // увеличенный размер
              ),
              onPressed: () => onItemSelected(index),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
