import '../../../../shared/types/result.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/models/user_model.dart';

class LoginUseCase {
  final AuthApi _api;

  LoginUseCase(this._api);


  Future<Result<(String token, UserModel user)>> call(String username, String password) async {
    try {
      final token = await _api.login(username, password);
      final user = await _api.getCurrentUser(token);
      return Success((token, user));
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', '')); // можешь прокинуть e.toString()
    }
  }
}


