import 'package:go_router/go_router.dart';
import 'package:last_mile_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/pages/delivery_list_page.dart';
import 'package:last_mile_mobile/features/scan/presentation/pages/scan_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/deliveries',
        builder: (context, state) => const DeliveryListPage(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanPage(),
      ),
    ],
  );
}
