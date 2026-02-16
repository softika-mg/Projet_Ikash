import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart'; // Pour les SMS

import 'core/app_theme.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'views/splash_screen.dart';

void main() async {
  // Indispensable pour initialiser les plugins natifs (SQLite, SMS)
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Créer le container unique pour accéder aux services avant le runApp
  final container = ProviderContainer();

  try {
    // 2. Initialiser la base de données (Création des comptes Admin/Agent par défaut)
    final authService = container.read(authServiceProvider);
    await authService.seedDatabase();

    // 3. (Optionnel mais recommandé) Demander la permission SMS dès le début
    // Tu peux aussi le faire plus tard dans l'AgentHome
    await Permission.sms.request();
  } catch (e) {
    debugPrint("Erreur lors de l'initialisation : $e");
  }

  runApp(
    // On utilise UncontrolledProviderScope car on a déjà créé notre container
    UncontrolledProviderScope(container: container, child: const IkashApp()),
  );
}

class IkashApp extends ConsumerWidget {
  const IkashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute les changements de thème et d'utilisateur
    final isDarkMode = ref.watch(themeProvider);

    // On utilise ShadcnApp (qui enveloppe MaterialApp) pour profiter
    // des composants Shadcn comme les Toasts ou les Tooltips.
    return MaterialApp(
      title: 'iKash',
      debugShowCheckedModeBanner: false,

      // Configuration du thème via ton AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // La page de démarrage qui décidera du chemin (Login ou Home)
      home: const SplashScreen(),
    );
  }
}
