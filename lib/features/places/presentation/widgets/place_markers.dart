import 'package:flutter/material.dart';
import '../../../places/data/place_positions.dart';
import '../../../places/domain/place.dart';
import '../../../places/presentation/widgets/place_booking_modal.dart';

class PlaceMarkers extends StatelessWidget {
  final List<Place> visiblePlaces;
  final double imageWidth;
  final double imageHeight;
  final bool isMobile;

  const PlaceMarkers({
    super.key,
    required this.visiblePlaces,
    required this.imageWidth,
    required this.imageHeight,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: visiblePlaces.map((place) {
        final pos = placePositions.firstWhere((p) => p.placeCode == place.placeCode);
        return Positioned(
          top: pos.top * imageHeight,
          left: pos.left * imageWidth,
          child: Column(
            children: [
              MouseRegion(
                cursor: place.booking == null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.forbidden,
                child: GestureDetector(
                  onTap: place.booking != null
                      ? null
                      : () {
                    showDialog(
                      context: context,
                      builder: (_) => PlaceBookingModal(
                        selectedPlaceCode: place.placeCode,
                      ),
                    );
                  },
                  child: Container(
                    width: isMobile ? 28 : 36,
                    height: isMobile ? 28 : 36,
                    decoration: BoxDecoration(
                      color: place.booking != null
                          ? Colors.grey
                          : const Color(0xFF15A696),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      place.booking != null
                          ? (place.booking!.employee.lastName.isNotEmpty
                          ? place.booking!.employee.lastName[0].toUpperCase()
                          : '?')
                          : place.placeCode,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (place.booking != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${place.booking!.employee.lastName[0]}. ${place.booking!.employee.firstName}',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
