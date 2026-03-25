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
        emit(DeliveryLoaded(optimizedList, isOptimized: true));
      } catch (e) {
        emit(DeliveryError(e.toString()));
        emit(DeliveryLoaded(currentState.deliveries)); // rollback
      }
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await deliveryRepo.updateStatus(id, status);
      await loadDeliveries(); // Reload to reflect changes
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }
}
