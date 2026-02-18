import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String _pin = "";
  bool _isError = false;

  void _onKeyTap(String value) async {
    if (_pin.length < 4) {
      setState(() {
        _isError = false; // Reset l'erreur quand on tape
        _pin += value;
      });

      if (_pin.length == 4) {
        // 'user' sera soit un objet Profile, soit null
        final user = await ref.read(authServiceProvider).login(_pin);

        // Au lieu de 'if (success)', on vérifie si l'utilisateur existe
        if (user != null) {
          if (!mounted) return;

          // Connexion réussie !
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        } else {
          // Connexion échouée (PIN incorrect)
          setState(() {
            _isError = true;
            _pin = "";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Code PIN incorrect"),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // --- Ton Logo avec Animation ---
            Image.asset('assets/icons/Icon.png', width: 100, height: 100)
                .animate(target: _isError ? 1 : 0)
                .shake(hz: 4, curve: Curves.easeInOut) // Secoue si erreur
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms),

            const SizedBox(height: 24),

            Text(
              "iKash Mobile",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Entrez votre code pour continuer",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 48),

            // --- Indicateurs de PIN (les petits ronds) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.all(12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pin.length > index
                        ? theme.primaryColor
                        : theme.primaryColor.withOpacity(0.15),
                    border: Border.all(
                      color: _isError
                          ? Colors.red
                          : theme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ).animate(target: _isError ? 1 : 0).shakeX(),
              ),
            ),

            const Spacer(),

            // --- Pavé Numérique ---
            _buildPinPad(theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPinPad(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          for (var i = 1; i <= 9; i++) _pinButton(i.toString(), theme),
          const SizedBox.shrink(),
          _pinButton("0", theme),
          IconButton(
            onPressed: () {
              if (_pin.isNotEmpty) {
                setState(() => _pin = _pin.substring(0, _pin.length - 1));
              }
            },
            icon: const Icon(Icons.backspace_outlined, size: 28),
            color: theme.primaryColor.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _pinButton(String text, ThemeData theme) {
    return InkWell(
      onTap: () => _onKeyTap(text),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor.withOpacity(0.05),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
