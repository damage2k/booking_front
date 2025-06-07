import 'package:flutter/material.dart';

class BookingHomePage extends StatelessWidget {
  const BookingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бронирование рабочих мест'),
      ),
      body: const Center(
        child: Text('Добро пожаловать в систему бронирования'),
      ),
    );
  }
}
