import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'main_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // On simule un petit temps de chargement (ex: initialisation DB)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Logique de redirection : si utilisateur connecté -> MainShell, sinon -> Login
    final user = ref.read(currentUserProvider);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user == null ? const LoginPage() : const MainShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Ton Icône ---
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1200),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Image.asset(
                    'assets/icons/Icon.png',
                    width: 120,
                    height: 120,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // --- Petit indicateur de chargement discret ---
            SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "iKash",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.primaryColor,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
