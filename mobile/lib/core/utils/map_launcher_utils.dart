import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherUtils {
  /// Abre o Google Maps em modo de navegação para as coordenadas dadas.
  static Future<void> openGoogleMapsNavigation(BuildContext context, double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showError(context, 'Não foi possível abrir o mapa. Instale o app de mapas.');
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Erro inesperado ao tentar abrir o mapa.');
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
    );
  }
}
