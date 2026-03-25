import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:last_mile_mobile/core/utils/map_launcher_utils.dart';
import 'package:last_mile_mobile/core/state/delivery_cubit.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/manual_delivery_sheet.dart';

class DeliveryListPage extends StatefulWidget {
  const DeliveryListPage({super.key});

  @override
  State<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> {
  @override
  void initState() {
    super.initState();
    // Load deliveries from NestJS
    context.read<DeliveryCubit>().loadDeliveries();
  }

  void _handleOptimize() {
    final state = context.read<DeliveryCubit>().state;
    if (state is DeliveryLoaded && state.deliveries.isNotEmpty) {
       final payload = {
          "depot": { "id": "depot", "latitude": -23.5505, "longitude": -46.6333 },
          "deliveries": state.deliveries.map((e) {
             final location = e['location'];
             double lat = -23.5505; 
             double lon = -46.6333;
             
             if (location != null && location is Map && location['coordinates'] != null) {
                final coords = location['coordinates'] as List;
                if (coords.length >= 2) {
                  lon = (coords[0] as num).toDouble();
                  lat = (coords[1] as num).toDouble();
                }
             }
             
             return {
                "id": e['id'].toString(), 
                "latitude": lat, 
                "longitude": lon
             };
          }).toList()
       };
       context.read<DeliveryCubit>().optimizeRoute(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Minhas Entregas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt, color: Colors.white),
            tooltip: 'Adicionar Manualmente',
            onPressed: () {
               showModalBottomSheet(
                 context: context,
                 isScrollControlled: true,
                 backgroundColor: Colors.transparent,
                 builder: (_) => BlocProvider.value(
                    value: context.read<DeliveryCubit>(),
                     child: const ManualDeliverySheet(),
                 ),
               );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bolt, color: Color(0xFFF97316)),
            tooltip: 'Otimizar Rota',
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Conectando ao Otimizador de Rotas...')),
               );
               _handleOptimize();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<DeliveryCubit, DeliveryState>(
            listener: (context, state) {
              if (state is DeliveryError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
              } else if (state is DeliveryLoaded && state.isOptimized) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rota Otimizada com Sucesso!'), backgroundColor: Colors.green));
              }
            },
            builder: (context, state) {
              if (state is DeliveryLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));
              } else if (state is DeliveryLoaded) {
                 return _buildContent(state.deliveries);
              }
              return const Center(child: Text('Nenhuma entrega carregada.', style: TextStyle(color: Colors.white54)));
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/scan'),
        label: const Text('Escanear Pacote'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildContent(List<dynamic> deliveries) {
    if (deliveries.isEmpty) {
      return const Center(child: Text('Você não tem entregas pendentes. Escaneie um pacote.', style: TextStyle(color: Colors.white54)));
    }
    
    final pending = deliveries.where((d) => d['status'] == 'PENDING').length;
    final inTransit = deliveries.where((d) => d['status'] == 'IN_TRANSIT').length;
    final delivered = deliveries.where((d) => d['status'] == 'DELIVERED').length;

    return Column(
      children: [
        _buildSummaryCard(pending, inTransit, delivered),
        const SizedBox(height: 24),
        if (deliveries.any((d) => d['status'] != 'DELIVERED')) 
           _buildNextDeliveryHeader(context, deliveries.firstWhere((d) => d['status'] != 'DELIVERED')),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: deliveries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildDeliveryCard(deliveries[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int pending, int inTransit, int delivered) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: 'Pendente', value: pending.toString(), color: Colors.orange),
          _SummaryItem(label: 'Em Rota', value: inTransit.toString(), color: Colors.blue),
          _SummaryItem(label: 'Concluído', value: delivered.toString(), color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(dynamic delivery) {
    final bool isDelivered = delivery['status'] == 'DELIVERED';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: isDelivered ? Border.all(color: Colors.green.withOpacity(0.5)) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF334155),
            child: Icon(isDelivered ? Icons.check_circle : Icons.location_on, color: isDelivered ? Colors.green : const Color(0xFFF97316)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(delivery['customerName'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text(delivery['address'] ?? 'Endereço Indisponível', style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          if (!isDelivered) 
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Marcar entregue',
              onPressed: () {
                 context.read<DeliveryCubit>().updateStatus(delivery['id'], 'DELIVERED');
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atualizando status no servidor...')));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNextDeliveryHeader(BuildContext context, dynamic delivery) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF97316).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF97316).withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
               Icon(Icons.directions_car, color: Color(0xFFF97316)),
               SizedBox(width: 8),
               Text('Próxima Entrega', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(delivery['customerName'] ?? 'Cliente Atual', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          Text(delivery['address'] ?? 'Endereço', style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                final location = delivery['location'];
                double lat = -23.5505;
                double lon = -46.6333;
                if (location != null && location is Map && location['coordinates'] != null) {
                   final coords = location['coordinates'] as List;
                   if (coords.length >= 2) {
                     lon = (coords[0] as num).toDouble();
                     lat = (coords[1] as num).toDouble();
                   }
                }
                MapLauncherUtils.openGoogleMapsNavigation(context, lat, lon);
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Navegar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      )
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }
}
