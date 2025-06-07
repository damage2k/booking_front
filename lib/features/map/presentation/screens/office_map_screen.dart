import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class OfficeMapScreen extends ConsumerStatefulWidget {
  const OfficeMapScreen({super.key});

  @override
  ConsumerState<OfficeMapScreen> createState() => _OfficeMapScreenState();
}

class _OfficeMapScreenState extends ConsumerState<OfficeMapScreen> {
  final ScrollController horizontalController = ScrollController();

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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 32,
              vertical: isMobile ? 12 : 24,
            ),
            child: Column(
              children: [
                // Контейнер с синей рамкой и картой
                Expanded(
                  child: RawScrollbar(
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12), // скругление самой картинки
                              child: Image.asset(
                                'assets/images/office_map_example.png',
                                fit: BoxFit.contain,
                                height: MediaQuery.of(context).size.height - 200,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //
                // const SizedBox(height: 12),
                //
                // // Горизонтальный скроллбар
                // SizedBox(
                //   height: 12,
                //   child: RawScrollbar(
                //     controller: horizontalController,
                //     thumbColor: const Color(0xFF005AA9),
                //     trackColor: Colors.grey.shade300,
                //     radius: const Radius.circular(6),
                //     thickness: 10,
                //     thumbVisibility: true,
                //     trackVisibility: true,
                //     child: ListView(
                //       controller: horizontalController,
                //       scrollDirection: Axis.horizontal,
                //       children: [
                //         const SizedBox(width: 2000), // фиксированный скроллируемый диапазон
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
