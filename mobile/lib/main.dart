import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:last_mile_mobile/core/theme/app_theme.dart';
import 'package:last_mile_mobile/features/delivery_list/presentation/pages/delivery_list_page.dart';

void main() {
  runApp(const LastMileApp());
}

class LastMileApp extends StatelessWidget {
  const LastMileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Last Mile Pro',
      theme: AppTheme.darkTheme,
      home: const DeliveryListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
