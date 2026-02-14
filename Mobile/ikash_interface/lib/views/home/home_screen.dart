import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // On récupère les textes en Malagasy pour coller à ton Figma
    final texts = AppStrings.translations['mg']!;

    return Scaffold(
      body: Stack(
        children: [
          // Les formes organiques en bas (à remplacer par ton export Figma plus tard)
          Positioned(
            bottom: -60,
            left: -30,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: AppTheme.accentBlue.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ton Logo "i" stylisé
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "i",
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Titre "Salama !"
                    Text(
                      texts['welcome']!,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sous-titre
                    Text(
                      texts['subtitle']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 80),

                    // Bouton "Hanomboka" ou "Hiditra"
                    ElevatedButton(
                      onPressed: () {
                        // Navigation vers la page de Login que tu viens de finaliser
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text(texts['btn_enter']!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
