import 'package:dio/dio.dart';
import 'package:last_mile_mobile/core/network/api_client.dart';

class DeliveryRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> fetchDeliveries() async {
    try {
      final response = await _apiClient.dio.get('/deliveries');
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Erro ao buscar entregas: $e');
    }
  }

  Future<List<dynamic>> fetchHistory(String id) async {
    try {
      final response = await _apiClient.dio.get('/deliveries/$id/history');
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Erro ao buscar histórico: $e');
    }
  }

  Future<dynamic> createDelivery(String qrCodeData) async {
    try {
      // Mock Data to save in Postgres when scanning
      final payload = {
        "customerName": "Scanned Pkg: ${qrCodeData.substring(0, 5)}...",
        "address": "Av Paulista, 1000 - Centro",
        "qrCodeId": qrCodeData,
      };
      final response = await _apiClient.dio.post('/deliveries', data: payload);
      return response.data;
    } catch (e) {
      throw Exception('Erro ao salvar nova entrega: $e');
    }
  }

  Future<void> updateStatus(String id, String status, {String? notes}) async {
    try {
       final Map<String, dynamic> body = {"status": status};
       if (notes != null && notes.isNotEmpty) {
         body["notes"] = notes;
       }
       await _apiClient.dio.patch('/deliveries/$id', data: body);
    } catch (e) {
       throw Exception('Erro ao atualizar status: $e');
    }
  }

  Future<void> createManualDelivery(String name, String address) async {
    // 1. Geocoding via OpenStreetMap (Nominatim)
    // Extrai o endereço sem o complemento para buscar as coordenadas com mais precisão
    final String addressForGeo = address.split(' - ')[0];

    final osmDio = Dio();
    // User-Agent is required by Nominatim's usage policy
    osmDio.options.headers['User-Agent'] = 'RotasApp/1.0';

    final osmUrl =
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(addressForGeo)}'
        '&format=json&limit=1&countrycodes=br';

    try {
      final geoResponse = await osmDio.get(osmUrl);

      // ── Hard fail if geocoding returns no results ──────────────────
      if (geoResponse.statusCode != 200 ||
          geoResponse.data is! List ||
          (geoResponse.data as List).isEmpty) {
        throw Exception(
          'Endereço não encontrado: "$addressForGeo".\n'
          'Verifique o endereço e tente novamente ou inclua a cidade '
          '(ex: "Rua X, 100, Campinas, SP").',
        );
      }

      final result = geoResponse.data[0];
      // Send as GeoJSON so NestJS/TypeORM handles it natively
      final locationObj = {
        "type": "Point",
        "coordinates": [
          double.parse(result['lon'] as String),
          double.parse(result['lat'] as String),
        ],
      };

      // 2. Save in backend
      final Map<String, dynamic> payload = {
        "customerName": name,
        "address": address,
        "location": locationObj,
      };

      await _apiClient.dio.post('/deliveries', data: payload);
    } on DioException catch (e) {
      if (e.response?.statusCode != null) {
        throw Exception(
          'Falha ao buscar coordenadas (HTTP ${e.response!.statusCode}). '
          'Verifique sua conexão e tente novamente.',
        );
      }
      throw Exception('Sem conexão ao buscar coordenadas. Verifique sua internet.');
    } catch (e) {
      // Re-throw our own descriptive messages unchanged
      rethrow;
    }
  }
}
