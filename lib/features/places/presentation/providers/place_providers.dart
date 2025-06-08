import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/types/result.dart';
import '../../../map/presentation/providers/date_provider.dart';
import '../../data/datasources/places_api.dart';
import '../../domain/place.dart';

final placesApiProvider = Provider<PlacesApi>((ref) => PlacesApi());

final placesForDateProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final api = ref.read(placesApiProvider);
  final result = await api.getPlacesForDate(date);

  switch (result) {
    case Success(:final data):
      return data;
    case Failure(:final message):
      throw Exception(message);
  }
});

