import 'package:booking_front/features/meeting/presentation/widgets/participant_selector.dart';
import 'package:booking_front/shared/ui/primary_button.dart';
import 'package:booking_front/shared/ui/generic_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/types/result.dart';
import '../../../../shared/ui/time_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../map/presentation/providers/date_provider.dart';
import '../../../settings/presentation/providers/application_settings_providers.dart';
import '../../data/datasources/meeting_room_api.dart';
import '../../domain/participant.dart';
import '../providers/participants_providers.dart';


class MeetingRoomBookingModal extends ConsumerStatefulWidget {
  final int meetingRoomId;
  final String roomName;

  const MeetingRoomBookingModal({
    super.key,
    required this.meetingRoomId,
    required this.roomName,
  });

  @override
  ConsumerState<MeetingRoomBookingModal> createState() =>
      _MeetingRoomBookingModalState();
}

class _MeetingRoomBookingModalState
    extends ConsumerState<MeetingRoomBookingModal> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  final List<Participant> selectedParticipants = [];

  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    _topicController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(participantQueryProvider.notifier).state = '';
    });
  }


  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final api = MeetingRoomsApi();
    final date = ref.read(selectedDateProvider);
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    setState(() {
      isLoading = true;
      error = null;
    });

    final result = await api.createRoomBooking(
      meetingRoomId: widget.meetingRoomId,
      date: formattedDate,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      topic: _topicController.text,
      participants: selectedParticipants,
    );

    switch (result) {
      case Success():
        if (mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (_) => const GenericSuccessDialog(
              title: 'Успешно!',
              message: 'Переговорная комната забронирована.',
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

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420,  maxHeight:  600, ),
          child: settingsAsync.when(
            loading: () => const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Ошибка настроек: $e'),
            data: (settings) {
              final startLimit = settings.get<String>(
                  "BOOKING_ROOMS_ALLOWED_START_TIME") ??
                  "09:00";
              final endLimit = settings.get<String>(
                  "BOOKING_ROOMS_ALLOWED_END_TIME") ??
                  "18:00";

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Бронирование',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Тема собрания',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Введите тему' : null,
                    ),
                    const SizedBox(height: 16),

                    TimeField(
                      controller: _startTimeController,
                      label: 'С',
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Введите время';
                        if (!_isValidTime(val, startLimit, endLimit)) {
                          return 'Вне допустимого времени ($startLimit–$endLimit)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TimeField(
                      controller: _endTimeController,
                      label: 'До',
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Введите время';
                        if (!_isValidTime(val, startLimit, endLimit)) {
                          return 'Вне допустимого времени ($startLimit–$endLimit)';
                        }
                        return null;
                      },
                    ),

                    ParticipantSelector(
                      selected: selectedParticipants,
                      onChanged: (list) => setState(() => selectedParticipants
                        ..clear()
                        ..addAll(list)),
                    ),

                    const SizedBox(height: 32),

                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(error!,
                            style: const TextStyle(color: Colors.red)),
                      ),

                    PrimaryButton(
                      onPressed: isLoading ? null : _handleBooking,
                      isLoading: isLoading,
                      isEnabled: true,
                      text: 'Забронировать',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isValidTime(String time, String startLimit, String endLimit) {
    try {
      final format = DateFormat.Hm();

      // обрезаем до HH:mm
      final cleanStart = startLimit.substring(0, 5);
      final cleanEnd = endLimit.substring(0, 5);

      final t = format.parseStrict(time);
      final min = format.parseStrict(cleanStart);
      final max = format.parseStrict(cleanEnd);

      return (t.isAfter(min) || t.isAtSameMomentAs(min)) &&
          (t.isBefore(max) || t.isAtSameMomentAs(max));
    } catch (_) {
      return false;
    }
  }

}
