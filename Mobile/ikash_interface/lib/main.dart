import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flex_color_scheme/flex_color_scheme.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'core/app_theme.dart';
import 'providers/theme_provider.dart';
import 'database/app_database.dart';
import 'services/auth_service.dart';
//import 'views/login_page.dart';
//import 'views/main_shell.dart';
import 'views/splash_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final container = ProviderContainer();

  // On crée le service. Note : On peut passer 'container'
  // car ProviderContainer implémente l'interface de lecture (ProviderReader)
  final authService = AuthService(database, container);

  await authService.seedDatabase();

  runApp(
    UncontrolledProviderScope(container: container, child: const IkashApp()),
  );
}

class IkashApp extends ConsumerWidget {
  const IkashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le provider moderne (Notifier) que l'on a créé
    final isDarkMode = ref.watch(themeProvider);
    final currentUser = ref.watch(currentUserProvider);

    return MaterialApp(
      title: 'iKash',
      debugShowCheckedModeBanner: false,

      // Utilisation des thèmes FlexScheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Basculement dynamique
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const SplashScreen(),
    );
  }
}
