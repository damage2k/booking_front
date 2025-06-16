import 'package:booking_front/features/auth/presentation/screens/login_launcher.dart';
import 'package:booking_front/features/meeting/data/datasources/meeting_room_api.dart';
import 'package:booking_front/features/profile/presentation/widgets/profile_bookings.dart';
import 'package:booking_front/shared/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../map/presentation/providers/date_provider.dart';

class ProfileModal extends ConsumerStatefulWidget {
  const ProfileModal({super.key});

  @override
  ConsumerState<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends ConsumerState<ProfileModal> {
  int selectedTab = 0;

  Future<void> _logout() async {
    await TokenStorage.clearToken();
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(userProvider.notifier).state = null;
    Navigator.of(context).pop();

    Future.microtask(() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LoginLauncher(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const SizedBox.shrink();

    final fullName =
    '${user.lastName} ${user.firstName} ${user.middleName ?? ''}'.trim();
    final initials = user.firstName[0].toUpperCase();

    final today = ref.watch(selectedDateProvider);
    final formattedToday = DateFormat('yyyy-MM-dd').format(today);

    final roomApi = MeetingRoomsApi();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              CircleAvatar(
                radius: 28,
                child: Text(initials, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 12),
              Text(fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TabButton(
                      label: 'Профиль',
                      index: 0,
                      selected: selectedTab == 0,
                      onTap: () => setState(() => selectedTab = 0)),
                  _TabButton(
                      label: 'Бронирование',
                      index: 1,
                      selected: selectedTab == 1,
                      onTap: () => setState(() => selectedTab = 1)),
                  _TabButton(
                      label: 'Статистика',
                      index: 2,
                      selected: selectedTab == 2,
                      onTap: () => setState(() => selectedTab = 2)),
                ],
              ),
              const SizedBox(height: 24),

              if (selectedTab == 0) ...[
                _infoField(label: 'Фамилия', value: user.lastName),
                _infoField(label: 'Имя', value: user.firstName),
                _infoField(label: 'Отчество', value: user.middleName ?? ''),
                _infoField(label: 'Должность', value: user.position ?? ''),
                _infoField(
                    label: 'Команда',
                    value: user.team?['name'] ?? '',
                    hasArrow: true),
              ] else if (selectedTab == 1) ...[
                const ProfileBookings()
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoField(
      {required String label, required String value, bool hasArrow = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value.isNotEmpty ? value : '—',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  const _BookingCard({
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label,
        required this.index,
        required this.selected,
        required this.onTap,
        super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
