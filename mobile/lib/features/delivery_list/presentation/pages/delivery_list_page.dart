import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:last_mile_mobile/core/utils/map_launcher_utils.dart';
import 'package:last_mile_mobile/core/state/delivery_cubit.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/manual_delivery_sheet.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/delivery_confirmation_sheet.dart';

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
      // ── Hamburger drawer ─────────────────────────────────────────
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Minhas Entregas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Hamburger icon — calls Scaffold.of() via Builder to open the drawer
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      // No FloatingActionButton — moved into the drawer
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
    );
  }

  /// Side drawer with all secondary actions.
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ações',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    tooltip: 'Fechar menu',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),

            // ── Escanear Pacote ──────────────────────────────────────
            _DrawerItem(
              icon: Icons.qr_code_scanner,
              label: 'Escanear Pacote',
              iconColor: const Color(0xFFF97316),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/scan');
              },
            ),

            // ── Adicionar Manualmente ────────────────────────────────
            _DrawerItem(
              icon: Icons.add_location_alt,
              label: 'Adicionar Manualmente',
              iconColor: Colors.white,
              onTap: () {
                Navigator.of(context).pop();
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

            // ── Otimizar Rota ────────────────────────────────────────
            _DrawerItem(
              icon: Icons.bolt,
              label: 'Otimizar Rota',
              iconColor: const Color(0xFFF97316),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conectando ao Otimizador de Rotas...')),
                );
                _handleOptimize();
              },
            ),
          ],
        ),
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
            // Extra bottom padding so the FAB (removed) no longer clips the last item
            padding: const EdgeInsets.only(bottom: 16),
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
              onPressed: () async {
                // 1. Show confirmation sheet and wait for result
                final notes = await showModalBottomSheet<String?>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DeliveryConfirmationSheet(
                    customerName: delivery['customerName'] ?? 'Cliente',
                    address: delivery['address'] ?? '',
                  ),
                );

                // User cancelled
                if (notes == null || !mounted) return;

                // 2. Mark as delivered (with optional notes)
                await context.read<DeliveryCubit>().updateStatus(
                  delivery['id'],
                  'DELIVERED',
                  notes: notes.isNotEmpty ? notes : null,
                );
                if (!mounted) return;

                // 3. Find next pending delivery for auto-advance
                final state = context.read<DeliveryCubit>().state;
                dynamic nextDelivery;
                if (state is DeliveryLoaded) {
                  try {
                    nextDelivery = state.deliveries.firstWhere(
                      (d) => d['id'] != delivery['id'] && d['status'] != 'DELIVERED',
                    );
                  } catch (_) {
                    nextDelivery = null;
                  }
                }

                if (nextDelivery != null) {
                  final location = nextDelivery['location'];
                  double lat = -23.5505;
                  double lon = -46.6333;
                  if (location != null && location is Map && location['coordinates'] != null) {
                    final coords = location['coordinates'] as List;
                    if (coords.length >= 2) {
                      lon = (coords[0] as num).toDouble();
                      lat = (coords[1] as num).toDouble();
                    }
                  }
                  final captureLat = lat;
                  final captureLon = lon;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Entregue! Próxima: ${nextDelivery['customerName']}'),
                      backgroundColor: const Color(0xFF1E293B),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 6),
                      action: SnackBarAction(
                        label: 'Navegar',
                        textColor: const Color(0xFFF97316),
                        onPressed: () => MapLauncherUtils.openGoogleMapsNavigation(
                          context, captureLat, captureLon,
                        ),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Todas as entregas concluídas!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
              label: const Text('Ir para Próxima Entrega', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

/// A single tappable row inside the side drawer.
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      splashColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }
}
