import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:last_mile_mobile/core/state/delivery_cubit.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/delivery_confirmation_sheet.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/widgets/delivery_failure_sheet.dart';
import 'package:last_mile_mobile/core/utils/map_launcher_utils.dart';

class StreetDeliveriesSheet extends StatelessWidget {
  final String streetName;
  final List<dynamic> deliveries;
  final Map<String, int> orderMap;

  const StreetDeliveriesSheet({
    super.key,
    required this.streetName,
    required this.deliveries,
    this.orderMap = const {},
  });

  /// Extract the house number / unit from a full address string.
  /// E.g. "Rua X, 335, Campinas, SP" → "335"
  String _extractUnit(String address) {
    final parts = address.split(',');
    if (parts.length >= 2) return parts[1].trim();
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_city, color: Color(0xFFF97316), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Entregas na rua', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(
                      streetName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${deliveries.length} ${deliveries.length == 1 ? "entrega" : "entregas"}',
                  style: const TextStyle(color: Color(0xFFF97316), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10, height: 24),

          // ── Deliveries list
          Expanded(
            child: ListView.separated(
              itemCount: deliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final delivery = deliveries[index];
                final rawAddress = delivery['address'] ?? '';
                final unit = _extractUnit(rawAddress);
                final addressParts = rawAddress.split(' - ');
                final mainAddress = addressParts[0];
                final complement = addressParts.length > 1 ? addressParts.sublist(1).join(' - ') : null;

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.15),
                              child: Text(
                                unit,
                                style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            if (orderMap.containsKey(delivery['id'].toString()))
                              Positioned(
                                top: -6,
                                right: -6,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF97316),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${orderMap[delivery['id'].toString()]}',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          delivery['customerName'] ?? 'Cliente',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mainAddress, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            if (complement != null)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(complement, style: const TextStyle(color: Color(0xFFF97316), fontSize: 11)),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: [
                            // Failure button
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Falha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.zero,
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
                                    if (notes == null || !context.mounted) return;
                                    await context.read<DeliveryCubit>().updateStatus(delivery['id'], 'FAILED', notes: notes);
                                    if (context.mounted) Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Confirm delivery button
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Entregar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () async {
                                    final notes = await showModalBottomSheet<String?>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => DeliveryConfirmationSheet(
                                        customerName: delivery['customerName'] ?? 'Cliente',
                                        address: delivery['address'] ?? '',
                                      ),
                                    );
                                    if (notes == null || !context.mounted) return;
                                    await context.read<DeliveryCubit>().updateStatus(
                                      delivery['id'],
                                      'DELIVERED',
                                      notes: notes.isNotEmpty ? notes : null,
                                    );
                                    if (context.mounted) Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Navigate to street button
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.navigation),
              label: Text(
                'Navegar para $streetName',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final location = deliveries.first['location'];
                double lat = -23.5505;
                double lon = -46.6333;
                if (location != null && location is Map && location['coordinates'] != null) {
                  final coords = location['coordinates'] as List;
                  if (coords.length >= 2) {
                    lon = (coords[0] as num).toDouble();
                    lat = (coords[1] as num).toDouble();
                  }
                }
                Navigator.of(context).pop();
                MapLauncherUtils.openGoogleMapsNavigation(context, lat, lon);
              },
            ),
          ),
        ],
      ),
    );
  }
}
