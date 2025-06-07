import 'package:flutter/material.dart';
import '../../../shared/widgets/app_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          AppHeader(),
          Expanded(child: Center(child: Text('Добро пожаловать!'))),
        ],
      ),
    );
  }
}
