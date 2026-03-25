import 'package:last_mile_mobile/core/network/api_client.dart';

class RouteRepository {
  final ApiClient _apiClient;

  RouteRepository(this._apiClient);

  Future<List<dynamic>> optimizeRoute(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post('/routes/optimize', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as List<dynamic>;
      } else {
         throw Exception('Erro na API: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar com o servidor: $e');
    }
  }
}
