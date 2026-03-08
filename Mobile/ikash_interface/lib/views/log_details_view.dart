import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../core/utils/formatters.dart';
import 'package:intl/intl.dart';

class LogDetailView extends StatelessWidget {
  final Transaction transaction;
  final SmsReceivedData? sms;
  final Color opColor;

  const LogDetailView({
    super.key,
    required this.transaction,
    this.sms,
    required this.opColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMatch = sms != null && sms!.montant == transaction.montant;
    final isWarning = sms != null && !isMatch;
    final bool isManual = transaction.estSaisieManuelle;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Détails de réconciliation"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: opColor.withOpacity(0.1),
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Header de Statut (Validé / Alerte / Attente)
            _buildStatusHeader(isMatch, isWarning, sms == null),

            // 2. Info de Provenance (Saisie Manuelle vs Automatique)
            _buildProvenanceInfo(isManual, theme),

            const SizedBox(height: 30),

            // 3. Comparaison Côte à Côte
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildComparisonCard(
                    title: "Données App",
                    // Icône dynamique selon la provenance de la transaction

                    icon: isManual ? LucideIcons.pencil: LucideIcons.zap,
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
                    color: isMatch
                        ? Colors.green
                        : (isWarning ? Colors.red : Colors.orange),
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

            // 4. Preuve Brute ou Alerte de Manquant
            if (sms != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    "Preuve SMS (Texte brut)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildRawSmsContainer(sms!.rawBody, theme),
            ] else
              _buildMissingSmsAlert(isManual),

            const SizedBox(height: 40),

            // 5. Action corrective si incohérence
            if (isWarning) _buildErrorButton(),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS INTERNES ---

  Widget _buildProvenanceInfo(bool isManual, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isManual ? Colors.blue : Colors.purple).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isManual ? LucideIcons.hand : LucideIcons.zap,
              size: 18,
              color: isManual ? Colors.blue : Colors.purple,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isManual ? "SAISIE MANUELLE" : "EXTRACTION AUTOMATIQUE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isManual ? Colors.blue : Colors.purple,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isManual
                      ? "Cette transaction a été saisie par vos soins."
                      : "Transaction détectée par SMS et confirmée par l'application.",
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
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
                color: isPlaceholder ? Colors.grey.shade400 : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const Divider(height: 25),
          _buildSmallLabel("RÉFÉRENCE", reference, isMonospace: true),
          const SizedBox(height: 12),
          _buildSmallLabel("HEURE", date != null ? DateFormat('HH:mm:ss').format(date) : "--:--"),
        ],
      ),
    );
  }

  Widget _buildSmallLabel(String label, String value, {bool isMonospace = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: isMonospace ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRawSmsContainer(String body, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: opColor.withOpacity(0.2)),
      ),
      child: Text(
        body,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.6),
      ),
    );
  }

  Widget _buildMissingSmsAlert(bool isManual) {
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
              children: [
                const Text("Donnée SMS absente", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text(
                  isManual
                    ? "Normal : Vous avez choisi de forcer cette transaction manuellement."
                    : "Le message réseau n'a pas encore été reçu par l'appareil.",
                  style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(LucideIcons.alertCircle),
      label: const Text("SIGNALER UNE ERREUR", style: TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
