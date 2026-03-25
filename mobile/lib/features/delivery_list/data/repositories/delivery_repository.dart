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

  Future<void> updateStatus(String id, String status) async {
    try {
       await _apiClient.dio.patch('/deliveries/$id', data: {"status": status});
    } catch (e) {
       throw Exception('Erro ao atualizar status: $e');
    }
  }

  Future<void> createManualDelivery(String name, String address) async {
    try {
      // 1. Geocoding via OpenStreetMap (Nominatim) - Free API
      final osmDio = Dio();
      // Added countrycodes=br to ensure Brazilian results only
      final osmUrl = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1&countrycodes=br';
      final geoResponse = await osmDio.get(osmUrl);
      
      Map<String, dynamic>? locationObj;
      if (geoResponse.statusCode == 200 && geoResponse.data is List && geoResponse.data.isNotEmpty) {
        final result = geoResponse.data[0];
        // Send as a Map (Object) so NestJS/TypeORM handles it natively as GeoJSON
        locationObj = {
          "type": "Point",
          "coordinates": [
             double.parse(result['lon']), 
             double.parse(result['lat'])
          ]
        };
      }

      // 2. Save in backend
      final Map<String, dynamic> payload = {
        "customerName": name,
        "address": address,
      };
      
      if (locationObj != null) {
        payload["location"] = locationObj;
      }

      await _apiClient.dio.post('/deliveries', data: payload);
    } catch (e) {
      throw Exception('Erro ao processar endereço manualmente: $e');
    }
  }
}

