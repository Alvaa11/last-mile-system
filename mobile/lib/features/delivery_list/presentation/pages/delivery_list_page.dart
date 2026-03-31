import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:last_mile_mobile/core/utils/map_launcher_utils.dart';
import 'package:last_mile_mobile/core/state/delivery_cubit.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/manual_delivery_sheet.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/delivery_confirmation_sheet.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/delivery_history_sheet.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/delivery_failure_sheet.dart';

class DeliveryListPage extends StatefulWidget {
  const DeliveryListPage({super.key});

  @override
  State<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> {
  String _selectedTab = 'PENDING';

  @override
  void initState() {
    super.initState();
    // Load deliveries from NestJS
    context.read<DeliveryCubit>().loadDeliveries();
  }

  void _handleOptimize() {
    final state = context.read<DeliveryCubit>().state;
    if (state is DeliveryLoaded && state.deliveries.isNotEmpty) {
       final pendingDeliveries = state.deliveries.where((d) => d['status'] == 'PENDING').toList();
       
       if (pendingDeliveries.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Nenhuma entrega pendente para otimizar.'),
             backgroundColor: Colors.orange,
           ),
         );
         return;
       }

       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Conectando ao Otimizador de Rotas...')),
       );

       final payload = {
          "depot": { "id": "depot", "latitude": -23.5505, "longitude": -46.6333 },
          "deliveries": pendingDeliveries.map((e) {
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
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Nenhuma entrega pendente para otimizar.'),
           backgroundColor: Colors.orange,
         ),
       );
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
    final failed = deliveries.where((d) => d['status'] == 'FAILED').length;
    final delivered = deliveries.where((d) => d['status'] == 'DELIVERED').length;

    final filteredDeliveries = deliveries.where((d) => d['status'] == _selectedTab).toList();

    return Column(
      children: [
        _buildSummaryCard(pending, failed, delivered),
        const SizedBox(height: 24),
        if (_selectedTab == 'PENDING' && filteredDeliveries.isNotEmpty) ...[
          _buildNextDeliveryHeader(context, filteredDeliveries.first),
          const SizedBox(height: 24),
        ],
        if (filteredDeliveries.isEmpty)
          const Expanded(child: Center(child: Text('Nenhuma entrega nesta categoria.', style: TextStyle(color: Colors.white54))))
        else
          Expanded(
            child: ListView.separated(
              // Extra bottom padding so the FAB (removed) no longer clips the last item
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: filteredDeliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildDeliveryCard(filteredDeliveries[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(int pending, int failed, int delivered) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Pendentes', 
            value: pending.toString(), 
            color: Colors.orange,
            isSelected: _selectedTab == 'PENDING',
            onTap: () => setState(() => _selectedTab = 'PENDING'),
          ),
          _SummaryItem(
            label: 'Não entregues', 
            value: failed.toString(), 
            color: Colors.redAccent,
            isSelected: _selectedTab == 'FAILED',
            onTap: () => setState(() => _selectedTab = 'FAILED'),
          ),
          _SummaryItem(
            label: 'Entregues', 
            value: delivered.toString(), 
            color: Colors.green,
            isSelected: _selectedTab == 'DELIVERED',
            onTap: () => setState(() => _selectedTab = 'DELIVERED'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(dynamic delivery) {
    final bool isDelivered = delivery['status'] == 'DELIVERED';
    final bool isFailed = delivery['status'] == 'FAILED';
    final String rawAddress = delivery['address'] ?? 'Endereço Indisponível';
    // Address is stored as "Rua X, 100, Cidade - Complemento"
    final List<String> addressParts = rawAddress.split(' - ');
    final String mainAddress = addressParts[0];
    final String? complement = addressParts.length > 1 ? addressParts.sublist(1).join(' - ') : null;

    final bool isFinished = isDelivered || isFailed;

    return GestureDetector(
      onTap: isFinished
          ? () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => DeliveryHistorySheet(delivery: delivery),
              );
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: isDelivered 
              ? Border.all(color: Colors.green.withValues(alpha: 0.5)) 
              : isFailed 
                  ? Border.all(color: Colors.redAccent.withValues(alpha: 0.5))
                  : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF334155),
                  child: Icon(
                    isDelivered ? Icons.check_circle : isFailed ? Icons.error_outline : Icons.location_on, 
                    color: isDelivered ? Colors.green : isFailed ? Colors.redAccent : const Color(0xFFF97316)
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(delivery['customerName'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text(mainAddress, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      if (complement != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            complement,
                            style: const TextStyle(color: Color(0xFFF97316), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (!isFinished) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close, size: 20),
                        label: const Text('Falha', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final notes = await showModalBottomSheet<String?>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => DeliveryFailureSheet(
                              customerName: delivery['customerName'] ?? 'Cliente',
                              address: delivery['address'] ?? '',
                            ),
                          );

                          if (notes == null || !mounted) return;

                          await context.read<DeliveryCubit>().updateStatus(
                            delivery['id'],
                            'FAILED',
                            notes: notes,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Entregar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
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
              ),
            ),
          ],
        ),
      ],
      if (isFailed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<DeliveryCubit>().updateStatus(
                      delivery['id'],
                      'PENDING',
                      notes: 'Reagendado para nova tentativa',
                    );
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Tentar Novamente', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryItem({
    required this.label, 
    required this.value, 
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
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
