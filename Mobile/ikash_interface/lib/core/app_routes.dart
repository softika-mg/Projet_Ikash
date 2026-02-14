import 'package:flutter/material.dart';
import '../views/home/home_screen.dart';
import '../views/auth/login_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      // dashboard: (context) => const DashboardScreen(),
    };
  }
}
