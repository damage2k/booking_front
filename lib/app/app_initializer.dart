import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/datasources/auth_api.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../shared/services/token_storage.dart';

Future<void> initializeApp(WidgetRef ref) async {
  final token = await TokenStorage.getToken();
  if (token == null) return;

  try {
    final user = await AuthApi().getCurrentUser(token);
    ref.read(authTokenProvider.notifier).state = token;
    ref.read(userProvider.notifier).state = user;
  } catch (_) {
    await TokenStorage.clearToken();
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(userProvider.notifier).state = null;
    ref.read(sessionExpiredProvider.notifier).state = true;
  }
}
