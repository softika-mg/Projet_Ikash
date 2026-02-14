import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminLogsView extends StatelessWidget {
  const AdminLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Utilisation de la couleur de fond du thème pour le support mode sombre
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Flux d'activités"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter, size: 20),
            onPressed: () {}, // Filtre par agent ou par statut
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 15,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          final isError = index == 3 || index == 7;
          return _buildLogTile(
            theme: theme,
            agent: index % 2 == 0 ? "Jean Marc" : "Faly R.",
            action: index % 3 == 0 ? "Dépôt validé" : "Retrait validé",
            time: "Il y a ${index + 2} min",
            status: isError ? "Erreur SMS" : "Succès",
            message: isError
                ? "Format SMS inconnu : 'Votre solde est...'"
                : "Réf: 87819102 | 45.000 Ar",
            isError: isError,
            isLast: index == 14, // Pour ne pas afficher la ligne après le dernier élément
          );
        },
      ),
    );
  }

  Widget _buildLogTile({
    required ThemeData theme,
    required String agent,
    required String action,
    required String time,
    required String status,
    required String message,
    required bool isError,
    bool isLast = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Indicateur visuel (Timeline) ---
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isError ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                    width: 2
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isError ? Colors.red : Colors.green).withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80, // Hauteur ajustée pour le contenu
                  color: isDark ? theme.dividerColor.withOpacity(0.2) : Colors.grey.shade200,
                ),
            ],
          ),
          const SizedBox(width: 16),

          // --- Contenu du Log ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      agent,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isError
                        ? (isDark ? Colors.redAccent : Colors.red)
                        : (isDark ? theme.colorScheme.secondary : Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),

                // --- Bloc de message (Style Log/Code) ---
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isError
                        ? Colors.red.withOpacity(isDark ? 0.15 : 0.05)
                        : (isDark ? theme.cardColor : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isError
                          ? Colors.red.withOpacity(0.2)
                          : theme.dividerColor.withOpacity(0.05),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isError
                          ? (isDark ? Colors.red.shade200 : Colors.red.shade800)
                          : (isDark ? theme.textTheme.bodyMedium?.color?.withOpacity(0.8) : Colors.grey.shade800),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Espace entre les logs
              ],
            ),
          ),
        ],
      ),
    );
  }
}
