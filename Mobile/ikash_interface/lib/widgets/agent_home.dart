import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_service.dart';
import '../views/add_transaction_view.dart';

class AgentHome extends ConsumerWidget {
  const AgentHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Message de Bienvenue ---
          Text(
            "Bonjour, ${user?.nom ?? 'Agent'}",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // --- Carte du Solde (Le "Hero" Widget) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withBlue(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Solde disponible",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  "1.250.000 Ar", // On dynamisera cela plus tard avec la DB
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildQuickStat(
                      LucideIcons.arrowUpCircle,
                      "Entrées",
                      "+45k",
                    ),
                    const SizedBox(width: 20),
                    _buildQuickStat(
                      LucideIcons.arrowDownCircle,
                      "Sorties",
                      "-12k",
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // --- Bouton d'Action SMS ---
          Text("Actions rapides", style: theme.textTheme.titleMedium),
          const SizedBox(height: 15),

          _buildActionButton(
            context: context,
            icon: LucideIcons.scanLine,
            label: "Synchroniser les SMS",
            subtitle: "Détecter les nouvelles transactions",
            onTap: () {
              // TODO: Lancer le service de lecture SMS
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Recherche de nouveaux SMS...")),
              );
            },
          ),
          _buildActionButton(
            context: context,
            icon: LucideIcons.plusCircle,
            label: "Saisie manuelle",
            subtitle: "Digitaliser une opération papier",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 18),
        const SizedBox(width: 5),
        Text(
          "$label: $value",
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
