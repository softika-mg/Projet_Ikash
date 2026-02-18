import 'package:flutter/material.dart';


class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // dashboard: (context) => const DashboardScreen(),
    };
  }
}
