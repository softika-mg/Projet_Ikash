import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("À propos"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Logo ou Icône principale
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.shieldCheck,
                size: 80,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Titre et Version
            const Text(
              "iKash Manager",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Version 1.0.0",
              style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.2),
            ),

            const SizedBox(height: 32),

            // Description détaillée
            Card(
              elevation: 0,
              color: theme.dividerColor.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Cette application est un outil complet de gestion pour les points de vente Mobile Money. "
                  "Elle permet d'automatiser le suivi des transactions, de gérer les soldes par opérateur "
                  "(Telma, Orange, Airtel) et d'assurer une traçabilité rigoureuse des activités des agents.",
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5, fontSize: 14),
                ),
              ),
            ),

            const Spacer(),

            // Crédits et Copyright
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Développé pour faciliter la gestion des\npoints de vente à Madagascar.",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              "© 2026 Lovasoa Nantenaina",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              "Tous droits réservés.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
