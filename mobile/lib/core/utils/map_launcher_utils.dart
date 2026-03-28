import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherUtils {
  /// Abre o Google Maps em modo de navegação turn-by-turn para as coordenadas dadas.
  /// Tenta primeiro o deep link nativo (google.navigation:) e cai no link web como fallback.
  static Future<void> openGoogleMapsNavigation(BuildContext context, double lat, double lng) async {
    // Deep link nativo: abre Google Maps direto no modo de navegação/rotas
    final Uri nativeUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    // Fallback web com modo de condução
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    try {
      bool launched = false;

      if (await canLaunchUrl(nativeUri)) {
        launched = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      if (!launched && context.mounted) {
        _showError(context, 'Não foi possível abrir o mapa. Instale o Google Maps.');
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
