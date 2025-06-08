class PlacePosition {
  final String placeCode;
  final double top;
  final double left;

  const PlacePosition({
    required this.placeCode,
    required this.top,
    required this.left,
  });
}

class _PlaceGroup {
  final String prefix;
  final double left;
  final int count;
  final int startFrom;
  final double topStep;


  const _PlaceGroup({
    required this.prefix,
    required this.left,
    required this.count,
    this.startFrom = 1,
    this.topStep = 0.088,
  });

  List<PlacePosition> generatePositions(final double topStart) {
    return List.generate(count, (i) {
      return PlacePosition(
        placeCode: '$prefix${startFrom + i}',
        top: topStart + i * topStep,
        left: left,
      );
    });
  }

}

List<PlacePosition> generateAllPlacePositions() {
  const topGroups = [
    _PlaceGroup(prefix: 'A', left: 0.025, count: 5),
    _PlaceGroup(prefix: 'A', left: 0.076, count: 5, startFrom: 6),
    _PlaceGroup(prefix: 'B', left: 0.142, count: 4),
    _PlaceGroup(prefix: 'B', left: 0.193, count: 5, startFrom: 5),
    _PlaceGroup(prefix: 'C', left: 0.260, count: 5),
    _PlaceGroup(prefix: 'C', left: 0.311, count: 5, startFrom: 6),
    _PlaceGroup(prefix: 'D', left: 0.377, count: 4),
    _PlaceGroup(prefix: 'D', left: 0.428, count: 5, startFrom: 5),
    _PlaceGroup(prefix: 'E', left: 0.494, count: 1),
    _PlaceGroup(prefix: 'E', left: 0.545, count: 1, startFrom: 2),
    _PlaceGroup(prefix: 'J', left: 0.609, count: 1),
    _PlaceGroup(prefix: 'J', left: 0.660, count: 1, startFrom: 2),
  ];

  final List<PlacePosition> result = topGroups.expand((group) => group.generatePositions(0.059)).toList();

  result.addAll(
      [
        PlacePosition(placeCode: "J3", top: 0.028, left: 0.712),
        PlacePosition(placeCode: "J4", top: 0.028, left: 0.753),
        PlacePosition(placeCode: "J5", top: 0.238, left: 0.758),
        PlacePosition(placeCode: "J6", top: 0.328, left: 0.758),
        PlacePosition(placeCode: "J7", top: 0.228, left: 0.688),
        PlacePosition(placeCode: "J8", top: 0.323, left: 0.688),
        PlacePosition(placeCode: "J9", top: 0.228, left: 0.633),
        PlacePosition(placeCode: "J10", top: 0.323, left: 0.633),

      ]
  );

  const bottomGroups = [
    _PlaceGroup(prefix: 'F', left: 0.022, count: 4),
    _PlaceGroup(prefix: 'F', left: 0.073, count: 4, startFrom: 5),
    _PlaceGroup(prefix: 'G', left: 0.120, count: 4),
    _PlaceGroup(prefix: 'G', left: 0.172, count: 4, startFrom: 5),
    _PlaceGroup(prefix: 'H', left: 0.219, count: 4),
    _PlaceGroup(prefix: 'H', left: 0.270, count: 4, startFrom: 5),
    _PlaceGroup(prefix: 'I', left: 0.317, count: 4),
    _PlaceGroup(prefix: 'I', left: 0.368, count: 4, startFrom: 5),
  ];

  result.addAll(bottomGroups.expand((group) => group.generatePositions(0.662)).toList());

  return result;
}

final List<PlacePosition> placePositions = generateAllPlacePositions();
