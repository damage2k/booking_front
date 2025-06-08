import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {

 return DateTime.now();

  //return DateTime.now().add(Duration(days: 1));
});
