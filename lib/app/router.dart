import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/booking/presentation/screens/booking_home_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BookingHomePage(),
    ),
    // добавим маршруты позже
  ],
);
