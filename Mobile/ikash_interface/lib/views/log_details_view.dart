import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../core/utils/formatters.dart';
import 'package:intl/intl.dart';

class LogDetailView extends StatelessWidget {
  final Transaction transaction;
  final SmsReceivedData? sms;
  final Color opColor; // On reçoit la couleur de la puce ici

  const LogDetailView({
    super.key,
    required this.transaction,
    this.sms,
    required this.opColor, // Requis pour la cohérence visuelle
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMatch = sms != null && sms!.montant == transaction.montant;
    final isWarning = sms != null && !isMatch;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Détails de réconciliation"),
        centerTitle: true,
        elevation: 0,
        // On donne une touche de la couleur opérateur à l'AppBar
        backgroundColor: opColor.withOpacity(0.1),
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER DE STATUT ---
            _buildStatusHeader(isMatch, isWarning, sms == null),

            const SizedBox(height: 30),

            // --- COMPARAISON CÔTE À CÔTE ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildComparisonCard(
                    title: "Saisie Agent",
                    icon: LucideIcons.user,
                    // Utilisation de la couleur de la puce (opColor)
                    color: opColor,
                    amount: transaction.montant,
                    reference: transaction.reference,
                    date: transaction.horodatage,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildComparisonCard(
                    title: "Données SMS",
                    icon: LucideIcons.messageSquare,
                    // Vert si ça match, sinon Rouge/Orange
                    color: isMatch ? Colors.green : (isWarning ? Colors.red : Colors.orange),
                    amount: sms?.montant ?? 0,
                    reference: sms?.reference ?? "Non reçu",
                    date: sms?.dateReception,
                    isPlaceholder: sms == null,
                    theme: theme,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- PREUVE BRUTE (SMS TEXT) ---
            if (sms != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text("Preuve SMS (Texte brut)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: opColor.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: opColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  sms!.rawBody,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ] else
              _buildMissingSmsAlert(),

            const SizedBox(height: 40),

            // --- BOUTON D'ACTION SI ERREUR ---
            if (isWarning)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () { /* Action de signalement */ },
                  icon: const Icon(LucideIcons.alertCircle),
                  label: const Text("SIGNALER UNE ERREUR", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  Widget _buildStatusHeader(bool isMatch, bool isWarning, bool isPending) {
    Color color = Colors.orange;
    String text = "EN ATTENTE DU SMS";
    IconData icon = LucideIcons.clock;

    if (isMatch) {
      color = Colors.green;
      text = "TRANSACTION VALIDÉE";
      icon = LucideIcons.shieldCheck;
    } else if (isWarning) {
      color = Colors.red;
      text = "ALERTE : INCOHÉRENCE";
      icon = LucideIcons.shieldAlert;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required IconData icon,
    required Color color,
    required double amount,
    required String reference,
    required ThemeData theme,
    DateTime? date,
    bool isPlaceholder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPlaceholder ? theme.dividerColor.withOpacity(0.1) : color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              isPlaceholder ? "---" : CurrencyFormatter.format(amount),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                color: isPlaceholder ? Colors.grey.shade400 : theme.textTheme.bodyLarge?.color
              ),
            ),
          ),
          const Divider(height: 25),
          const Text("RÉFÉRENCE", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(reference, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          const Text("HEURE", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            date != null ? DateFormat('HH:mm:ss').format(date) : "--:--",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingSmsAlert() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, color: Colors.orange, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("SMS non trouvé", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text(
                  "Le message de confirmation n'a pas encore été reçu ou analysé.",
                  style: TextStyle(fontSize: 12, color: Colors.orangeAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
