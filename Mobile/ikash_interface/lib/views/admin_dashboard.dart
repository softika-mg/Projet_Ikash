import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Couleur de fond adaptative (gris très clair ou noir profond)
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Espace pour la barre de statut
            Text(
              "Vue d'ensemble",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 20),

            // --- Cartes de Performance Globales ---
            Row(
              children: [
                _buildSummaryCard(
                  title: "Volume Total",
                  value: "45.8M Ar",
                  icon: LucideIcons.barChart3,
                  color: isDark ? Colors.indigo.shade400 : Colors.indigo,
                ),
                const SizedBox(width: 15),
                _buildSummaryCard(
                  title: "Agents Actifs",
                  value: "12 / 15",
                  icon: LucideIcons.users,
                  color: isDark ? Colors.green.shade600 : Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- Section Agents ---
            Text(
              "Top Agents (Aujourd'hui)",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildAgentRankCard(theme, "Jean Marc", "8.2M Ar", "24 ops", true),
            _buildAgentRankCard(theme, "Faly R.", "5.4M Ar", "18 ops", false),
            _buildAgentRankCard(theme, "Sitraka", "3.1M Ar", "12 ops", false),

            const SizedBox(height: 30),

            // --- Graphique de Répartition (Conteneur Thémé) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? theme.dividerColor.withOpacity(0.1) : Colors.grey.shade200,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Répartition par Opérateur",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildAdminProgress(
                    theme,
                    "TELMA / Mvola",
                    0.70,
                    Colors.yellow.shade800,
                  ),
                  _buildAdminProgress(theme, "ORANGE Money", 0.20, Colors.orange),
                  _buildAdminProgress(theme, "AIRTEL Money", 0.10, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentRankCard(
    ThemeData theme,
    String name,
    String volume,
    String ops,
    bool isTop,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop
              ? (isDark ? Colors.indigo.shade400 : Colors.indigo.shade200)
              : (isDark ? theme.dividerColor.withOpacity(0.1) : Colors.transparent),
          width: isTop ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade100,
            child: Icon(LucideIcons.user, size: 18, color: theme.primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                ),
                Text(
                  ops,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            volume,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProgress(ThemeData theme, String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withOpacity(0.1),
              color: color,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
