import 'package:booking_front/features/auth/presentation/screens/login_launcher.dart';
import 'package:booking_front/shared/ui/generic_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../../../../shared/ui/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../places/presentation/providers/booking_providers.dart';
import '../../../places/presentation/providers/place_providers.dart';

class ProfileModal extends ConsumerStatefulWidget {
  const ProfileModal({super.key});

  @override
  ConsumerState<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends ConsumerState<ProfileModal> {
  int selectedTab = 0;

  Future<void> _logout() async {
    await TokenStorage.clearToken(); // ✅ удалить токен из shared_preferences
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(userProvider.notifier).state = null;
    Navigator.of(context).pop();

    // Показать login модалку
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

    final fullName = '${user.lastName} ${user.firstName} ${user.middleName ?? ''}'.trim();
    final initials = user.firstName[0].toUpperCase();

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
              Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(user.email, style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 24),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TabButton(label: 'Профиль', index: 0, selected: selectedTab == 0, onTap: () => setState(() => selectedTab = 0)),
                  _TabButton(label: 'Бронирование', index: 1, selected: selectedTab == 1, onTap: () => setState(() => selectedTab = 1)),
                  _TabButton(label: 'Статистика', index: 2, selected: selectedTab == 2, onTap: () => setState(() => selectedTab = 2)),
                ],
              ),

              const SizedBox(height: 24),

              if (selectedTab == 0) ...[
                _infoField(label: 'Фамилия', value: user.lastName),
                _infoField(label: 'Имя', value: user.firstName),
                _infoField(label: 'Отчество', value: user.middleName ?? ''),
                _infoField(label: 'Должность', value: user.position ?? ''),
                _infoField(label: 'Команда', value: user.team?['name'] ?? '', hasArrow: true),
              ] else if (selectedTab == 1) ...[
                ref.watch(bookingsProvider).when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Ошибка: $e'),
                  data: (bookings) {
                    if (bookings.isEmpty) return const Text('Нет активных бронирований.');

                    return Column(
                      children: bookings.map((b) {
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
                                    Text(b.placeCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      b.bookingDate == DateTime.now().toString()
                                          ? 'Сегодня'
                                          : 'Завтра',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ConfirmDialog(
                                      title: 'Отмена бронирования',
                                      message: 'Вы уверены, что хотите отменить бронь?',
                                      onCancel: () => Navigator.of(context).pop(),
                                      onConfirm: () async {
                                        final api = ref.read(placesApiProvider);
                                        final result = await api.cancelBooking(b.id);

                                        if (context.mounted) {
                                          Navigator.of(context).pop(); // close confirm
                                        }

                                        switch (result) {
                                          case Success():
                                            ref.invalidate(bookingsProvider);
                                            ref.invalidate(placesForDateProvider);
                                            showDialog(
                                              context: context,
                                              builder: (_) =>  GenericSuccessDialog(
                                                title: 'Успешно',
                                                message: 'Бронирование отменено.',
                                              ),
                                            );
                                            break;
                                          case Failure(:final message):
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Ошибка'),
                                                content: Text(message),
                                              ),
                                            );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );

                      }).toList(),
                    );
                  },
                )
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

  Widget _infoField({required String label, required String value, bool hasArrow = false}) {
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
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value.isNotEmpty ? value : '—', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          hasArrow
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : const Icon(Icons.edit, size: 16, color: Colors.teal),
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

  const _TabButton({required this.label, required this.index, required this.selected, required this.onTap, super.key});

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
