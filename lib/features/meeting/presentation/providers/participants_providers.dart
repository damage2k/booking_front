import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/token_storage.dart';
import '../../../../shared/types/result.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/participant.dart';

final participantQueryProvider = StateProvider<String>((ref) => '');

final participantSearchProvider =
FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final query = ref.watch(participantQueryProvider);

  if (query.isEmpty) return [];

  // debounce 1 секунда
  await Future.delayed(const Duration(seconds: 1));

  final token = await TokenStorage.getToken();
  final dio = ApiClient.dio;

  final res = await dio.get(
    '/api/employees',
    options: Options(headers: {
      'Authorization': 'Bearer $token',
    }),
  );

  final users = (res.data as List)
      .map((e) => UserModel.fromJson(e))
      .where((u) => u.lastName.toLowerCase().contains(query.toLowerCase()))
      .toList();

  return users;
});
