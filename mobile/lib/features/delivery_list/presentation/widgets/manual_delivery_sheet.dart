import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:last_mile_mobile/core/state/delivery_cubit.dart';
import 'package:go_router/go_router.dart';

class ManualDeliverySheet extends StatefulWidget {
  const ManualDeliverySheet({super.key});

  @override
  State<ManualDeliverySheet> createState() => _ManualDeliverySheetState();
}

class _ManualDeliverySheetState extends State<ManualDeliverySheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _complementController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _submitted = true);
    
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    
    if (name.isEmpty || address.isEmpty) return;

    // Append complement to address so geocoding and the backend see the full info
    final complement = _complementController.text.trim();
    final fullAddress = complement.isNotEmpty ? '$address - $complement' : address;

    setState(() => _isLoading = true);

    await context.read<DeliveryCubit>().addManualDelivery(name, fullAddress);

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop(); // close sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adicionar Manualmente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Nome ──────────────────────────────────────────────────────
          _buildField(
            controller: _nameController,
            label: 'Nome do Cliente',
            icon: Icons.person_outline,
            errorText: _submitted && _nameController.text.trim().isEmpty 
                ? 'Campo obrigatório' 
                : null,
          ),
          const SizedBox(height: 12),

          // ── Endereço ──────────────────────────────────────────────────
          _buildField(
            controller: _addressController,
            label: 'Endereço (Rua, Número, Cidade)',
            hint: 'Ex: Rua Pedro Álvares Cabral, 826, Campinas',
            icon: Icons.location_on_outlined,
            errorText: _submitted && _addressController.text.trim().isEmpty 
                ? 'Campo obrigatório' 
                : null,
          ),
          const SizedBox(height: 12),

          // ── Complemento ───────────────────────────────────────────────
          _buildField(
            controller: _complementController,
            label: 'Complemento (opcional)',
            hint: 'Ex: Apto 12, Bloco B, Casa dos fundos',
            icon: Icons.apartment_outlined,
          ),
          const SizedBox(height: 24),

          // ── Botão ─────────────────────────────────────────────────────
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'ADICIONAR ENTREGA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) {
        if (_submitted) setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        labelStyle: TextStyle(color: errorText != null ? Colors.redAccent : Colors.white54),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        prefixIcon: Icon(icon, color: errorText != null ? Colors.redAccent : Colors.white38, size: 20),
      ),
    );
  }
}

