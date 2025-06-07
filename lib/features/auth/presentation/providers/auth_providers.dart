import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/login_usecase.dart';

// API
final authApiProvider = Provider((ref) => AuthApi());

// UseCase
final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.read(authApiProvider)));

// Auth state (токен)
final authTokenProvider = StateProvider<String?>((ref) => null);

final userProvider = StateProvider<UserModel?>((ref) => null);

final sessionExpiredProvider = StateProvider<bool>((ref) => false);
