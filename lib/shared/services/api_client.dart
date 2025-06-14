import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';


class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 120,
    ),
  );

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      // адрес твоего ПК в локальной сети
      return 'http://192.168.0.110:8080';
    }
  }
}
