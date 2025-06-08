import '../domain/place.dart';

List<Place> generateAllPlaces() {
  return [
    ..._generateRow('A', 1, 10),
    ..._generateRow('B', 1, 9),
    ..._generateRow('C', 1, 10),
    ..._generateRow('D', 1, 9),
    ..._generateRow('E', 1, 2),
    ..._generateRow('F', 1, 8),
    ..._generateRow('G', 1, 8),
    ..._generateRow('H', 1, 8),
    ..._generateRow('I', 1, 8),
    ..._generateRow('J', 1, 10),
  ];
}

List<Place> _generateRow(String row, int start, int end) {
  return List.generate(end - start + 1, (i) {
    final code = '$row${i + start}';
    return Place(
      placeId: code.hashCode,
      placeCode: code,
      booking: null,
      isLocked: false,
      hasSchedule: false,
    );
  });
}
