import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:last_mile_mobile/features/delivery_list/data/repositories/delivery_repository.dart';
import 'package:last_mile_mobile/features/delivery_list/data/repositories/route_repository.dart';

abstract class DeliveryState {}

class DeliveryInitial extends DeliveryState {}
class DeliveryLoading extends DeliveryState {}

class DeliveryLoaded extends DeliveryState {
  final List<dynamic> deliveries;
  final bool isOptimized;
  DeliveryLoaded(this.deliveries, {this.isOptimized = false});
}

class DeliveryError extends DeliveryState {
  final String message;
  DeliveryError(this.message);
}

class DeliveryCubit extends Cubit<DeliveryState> {
  final DeliveryRepository deliveryRepo;
  final RouteRepository routeRepo;

  DeliveryCubit({required this.deliveryRepo, required this.routeRepo}) : super(DeliveryInitial());

  Future<void> loadDeliveries() async {
    emit(DeliveryLoading());
    try {
      final data = await deliveryRepo.fetchDeliveries();
      emit(DeliveryLoaded(data));
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> scanAndCreate(String qrData) async {
    emit(DeliveryLoading());
    try {
      await deliveryRepo.createDelivery(qrData);
      await loadDeliveries(); // Reload list after creating
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> addManualDelivery(String name, String address) async {
    emit(DeliveryLoading());
    try {
      await deliveryRepo.createManualDelivery(name, address);
      await loadDeliveries(); // Reload
    } catch (e) {
      emit(DeliveryError(e.toString()));
      await loadDeliveries(); // try to rollback to loaded state
    }
  }

  Future<void> optimizeRoute(Map<String, dynamic> payload) async {
    final currentState = state;
    if (currentState is DeliveryLoaded) {
      emit(DeliveryLoading());
      try {
        final optimizedList = await routeRepo.optimizeRoute(payload);
        
        // 1. Extrair a ordem dos IDs otimizada pelo backend
        final List<String> optimizedIds = (optimizedList as List)
            .map((item) => item['id'].toString())
            .where((id) => id != 'depot')
            .toList();

        // 2. Pegar todas as entregas do estado atual
        final allDeliveries = List<dynamic>.from(currentState.deliveries);
        
        // 3. Separar as pendentes (que foram otimizadas) das demais
        final pending = allDeliveries.where((d) => d['status'] == 'PENDING').toList();
        final others = allDeliveries.where((d) => d['status'] != 'PENDING').toList();

        // 4. Reordenar as pendentes com base nos IDs otimizados
        pending.sort((a, b) {
            final aIndex = optimizedIds.indexOf(a['id'].toString());
            final bIndex = optimizedIds.indexOf(b['id'].toString());
            if (aIndex == -1 && bIndex == -1) return 0;
            if (aIndex == -1) return 1;
            if (bIndex == -1) return -1;
            return aIndex.compareTo(bIndex);
        });

        // 5. Recombinar a lista final
        final reorderedList = [...pending, ...others];

        emit(DeliveryLoaded(reorderedList, isOptimized: true));
      } catch (e) {
        emit(DeliveryError(e.toString()));
        emit(DeliveryLoaded(currentState.deliveries)); // rollback
      }
    }
  }

  Future<void> updateStatus(String id, String status, {String? notes}) async {
    try {
      await deliveryRepo.updateStatus(id, status, notes: notes);
      await loadDeliveries(); // Reload to reflect changes
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }
}
