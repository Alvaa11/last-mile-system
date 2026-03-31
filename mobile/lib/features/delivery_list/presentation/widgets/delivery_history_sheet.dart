import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:last_mile_mobile/core/state/delivery_cubit.dart';

class DeliveryHistorySheet extends StatefulWidget {
  final dynamic delivery;

  const DeliveryHistorySheet({super.key, required this.delivery});

  @override
  State<DeliveryHistorySheet> createState() => _DeliveryHistorySheetState();
}

class _DeliveryHistorySheetState extends State<DeliveryHistorySheet> {
  List<dynamic>? _history;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final repo = context.read<DeliveryCubit>().deliveryRepo;
      final data = await repo.fetchHistory(widget.delivery['id']);
      if (mounted) {
        setState(() {
          _history = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ─────────────────────────────────────────────
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

          // ── Title ────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.history, color: Colors.white54, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Histórico & Observações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Delivery info ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.delivery['customerName'] ?? 'Cliente',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.delivery['address'] ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── History List ─────────────────────────────────────────────
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF97316)),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar histórico.',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }
    if (_history == null || _history!.isEmpty) {
      return const Center(
        child: Text('Nenhum registro encontrado.', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.separated(
      itemCount: _history!.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(left: 19),
        child: Container(
          height: 24,
          width: 2,
          color: Colors.white10,
          alignment: Alignment.centerLeft,
        ),
      ),
      itemBuilder: (context, index) {
        final item = _history![index];
        final isDelivered = item['status'] == 'DELIVERED';
        final isFailed = item['status'] == 'FAILED';
        String tsString = item['timestamp'] ?? '';
        if (tsString.isNotEmpty && !tsString.endsWith('Z')) {
          tsString += 'Z';
        }
        final date = DateTime.tryParse(tsString)?.toLocal().subtract(const Duration(hours: 3));
        final formattedDate = date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
            : '';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDelivered 
                    ? Colors.green.withValues(alpha: 0.15) 
                    : isFailed 
                        ? Colors.redAccent.withValues(alpha: 0.15) 
                        : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDelivered ? Icons.check : isFailed ? Icons.close : Icons.circle,
                size: 14,
                color: isDelivered ? Colors.green : isFailed ? Colors.redAccent : Colors.white54,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDelivered 
                        ? Colors.green.withValues(alpha: 0.3) 
                        : isFailed 
                            ? Colors.redAccent.withValues(alpha: 0.3) 
                            : Colors.white10,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['status'] == 'DELIVERED'
                              ? 'Entregue'
                              : item['status'] == 'FAILED'
                                  ? 'Falha na Entrega'
                                  : item['status'] == 'IN_TRANSIT'
                                      ? 'Em Rota'
                                      : 'Pendente',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDelivered ? Colors.green : isFailed ? Colors.redAccent : Colors.white,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                    if (item['notes'] != null && item['notes'].toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.sticky_note_2_outlined, size: 14, color: Colors.white54),
                                SizedBox(width: 6),
                                Text('Observação', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['notes'],
                              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
