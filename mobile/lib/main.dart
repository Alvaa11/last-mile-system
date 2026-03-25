import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:last_mile_mobile/core/theme/app_theme.dart';
import 'package:last_mile_mobile/core/routes/app_router.dart';
import 'package:last_mile_mobile/core/network/api_client.dart';
import 'package:last_mile_mobile/features/delivery_list/data/repositories/delivery_repository.dart';
import 'package:last_mile_mobile/features/delivery_list/data/repositories/route_repository.dart';
import 'package:last_mile_mobile/core/state/delivery_cubit.dart';

void main() {
  runApp(const LastMileApp());
}

class LastMileApp extends StatelessWidget {
  const LastMileApp({super.key});

  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryCubit(
        deliveryRepo: DeliveryRepository(),
        routeRepo: RouteRepository(ApiClient()),
      ),
      child: MaterialApp.router(
        title: 'Last Mile Pro',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
