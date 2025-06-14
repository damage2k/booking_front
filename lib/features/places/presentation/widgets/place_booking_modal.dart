import 'package:booking_front/shared/ui/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/types/result.dart';
import '../../../../shared/ui/generic_success_dialog.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../map/presentation/providers/date_provider.dart';
import '../../../meeting/presentation/widgets/meeting_room_booking_form.dart';
import '../../domain/place.dart';
import '../providers/booking_providers.dart';
import '../providers/place_providers.dart';

class PlaceBookingModal extends ConsumerStatefulWidget {
  final String selectedPlaceCode;

  const PlaceBookingModal({super.key, required this.selectedPlaceCode});

  @override
  ConsumerState<PlaceBookingModal> createState() => _PlaceBookingModalState();
}

class _PlaceBookingModalState extends ConsumerState<PlaceBookingModal> {
  bool isLocked = false;
  int tabIndex = 0;
  String? selectedPlace;
  String? error;
  bool isLoading = false;
  List<Place> allPlaces = [];

  @override
  void initState() {
    super.initState();
    selectedPlace = widget.selectedPlaceCode;
  }

  Future<void> _handleBooking() async {
    final place = allPlaces.firstWhere((p) => p.placeCode == selectedPlace);
    final date = ref.read(selectedDateProvider);

    setState(() {
      isLoading = true;
      error = null;
    });

    final api = ref.read(placesApiProvider);
    final result = await api.bookPlace(
      placeId: place.placeId,
      date: date,
    );

    switch (result) {
      case Success():
        ref.invalidate(placesForDateProvider);
        ref.invalidate(bookingsProvider);
        if (mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (_) => GenericSuccessDialog(
              title: 'Бронирование успешно!',
              message: 'Место ${place.placeCode} забронировано.',
              iconColor: Colors.blue,
            ),
          );
        }
        break;

      case Failure(:final message):
        setState(() => error = message);
    }

    setState(() => isLoading = false);
  }

  Expanded _buildTab({required String title, required int index}) {
    final bool active = tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = index),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF005AA9) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF6D7B92),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceBookingForm(List<String> placeCodes) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedPlace,
          onChanged: (val) => setState(() => selectedPlace = val),
          items: placeCodes.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Text(code),
            );
          }).toList(),
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),

        PrimaryButton(
          onPressed: selectedPlace != null && !isLoading && !isLocked
              ? _handleBooking
              : null,
          isLoading: isLoading,
          isEnabled: !isLocked,
          text: "Забронировать",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isAdmin = user?.roles.contains('ROLE_ADMIN') ?? false;
    final placesAsync = ref.watch(placesForDateProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: placesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Ошибка загрузки мест: $e'),
            data: (places) {
              allPlaces = places;
              final placeCodes = places
                  .map((p) => p.placeCode)
                  .toList()
                ..sort();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Бронирование',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTab(title: 'Рабочие места', index: 0),
                        _buildTab(title: 'Переговорные', index: 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isAdmin && tabIndex == 0) ...[
                    Row(
                      children: [
                        const Text('Заблокировано', style: TextStyle(fontSize: 14)),
                        const Spacer(),
                        Switch(
                          value: isLocked,
                          onChanged: (v) => setState(() => isLocked = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  tabIndex == 0
                      ? _buildPlaceBookingForm(placeCodes)
                      : const MeetingRoomBookingForm(
                    meetingRoomId: 1,
                    roomName: 'MR1',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
