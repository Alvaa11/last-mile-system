import 'package:last_mile_mobile/core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['access_token'];
        _apiClient.setToken(token);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Erro ao fazer login. Verifique o usuário no banco de dados. $e');
    }
  }
}
