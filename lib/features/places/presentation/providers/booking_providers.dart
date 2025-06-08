
import 'package:booking_front/features/places/presentation/providers/place_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/types/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/booking.dart';

final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final api = ref.read(placesApiProvider);
  final user = ref.read(userProvider);

  if (user == null) throw 'Пользователь не найден';

  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));

  final result = await api.getUserBookings(
    from: now,
    to: tomorrow,
    userId: user.id,
  );

  return switch (result) {
    Success(:final data) => data,
    Failure(:final message) => throw message,
  };
});