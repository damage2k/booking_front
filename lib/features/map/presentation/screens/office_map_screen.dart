import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../places/data/place_positions.dart';
import '../../../places/presentation/providers/place_providers.dart';
import '../../../places/presentation/widgets/place_markers.dart';
import '../widgets/date_toggle.dart';

class OfficeMapScreen extends ConsumerStatefulWidget {
  const OfficeMapScreen({super.key});

  @override
  ConsumerState<OfficeMapScreen> createState() => _OfficeMapScreenState();
}

class _OfficeMapScreenState extends ConsumerState<OfficeMapScreen> {
  final ScrollController horizontalController = ScrollController();

  bool imageLoaded = false;
  double imageWidth = 0;

  @override
  void dispose() {
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authTokenProvider) != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (!isLoggedIn) {
      return const Center(
        child: Text(
          'Пожалуйста, войдите в систему, чтобы просматривать карту офиса.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final placesAsync = ref.watch(placesForDateProvider);

    if (placesAsync is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (placesAsync is AsyncError) {
      return Center(child: Text('Ошибка: ${placesAsync.error}'));
    }

    final places = placesAsync.value!;
    final visiblePlaces = places.where((place) {
      return placePositions.any((pos) => pos.placeCode == place.placeCode);
    }).toList();

    final imageHeight = MediaQuery.of(context).size.height - 200;

    // Загружаем изображение и вычисляем пропорциональную ширину
    final image = Image.asset(
      'assets/images/office_map_example.png',
      fit: BoxFit.contain,
      height: imageHeight,
    );

    if (!imageLoaded) {
      final stream = image.image.resolve(const ImageConfiguration());
      stream.addListener(
        ImageStreamListener((info, _) {
          setState(() {
            imageWidth = info.image.width.toDouble() * (imageHeight / info.image.height.toDouble());
            imageLoaded = true;
          });
        }),
      );
    }

    if (!imageLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 32,
          vertical: isMobile ? 12 : 24,
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Карта + скролл
                  RawScrollbar(
                    controller: horizontalController,
                    thumbColor: const Color(0xFF005AA9),
                    trackColor: Colors.grey.shade300,
                    radius: const Radius.circular(18),
                    trackRadius: const Radius.circular(18),
                    thickness: 10,
                    thumbVisibility: true,
                    trackVisibility: true,
                    notificationPredicate: (notification) => notification.depth == 0,
                    child: ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        controller: horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF9DB3E9), width: 12),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Stack(
                              children: [
                                // Карта
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: image,
                                ),

                                // Места
                                SizedBox(
                                  width: imageWidth,
                                  height: imageHeight,
                                  child: PlaceMarkers(
                                    visiblePlaces: visiblePlaces,
                                    imageWidth: imageWidth,
                                    imageHeight: imageHeight,
                                    isMobile: isMobile,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Переключатель Сегодня / Завтра
                  Positioned(
                    bottom: 64,
                    right: isMobile ? 16 : 24,
                    child: DateToggle(isMobile: isMobile),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
