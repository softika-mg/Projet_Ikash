import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../services/auth_service.dart';
import '../views/add_transaction_view.dart';
import '../services/sms_sync_service.dart';
import '../models/enum.dart';
import 'package:permission_handler/permission_handler.dart';
import '../views/history_view.dart';
import '../core/utils/formatters.dart';

class AgentHome extends ConsumerWidget {
  const AgentHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    final user = ref.watch(currentUserProvider);
    final pendingSmsAsync = ref.watch(pendingSmsCountProvider);

    final transactionsStream = db.watchAllTransactions();
    final pucesStream = db.watchAgentNumbers(1);

    return StreamBuilder<List<Transaction>>(
      stream: transactionsStream,
      builder: (context, txSnapshot) {
        final transactions = txSnapshot.data ?? [];

        // --- CALCUL DES STATISTIQUES DU JOUR ---
        double entrees = 0;
        double sorties = 0;
        double commissions = 0;

        for (var tx in transactions) {
          if (DateUtils.isSameDay(tx.horodatage, DateTime.now())) {
            if (tx.type == TransactionType.retrait) {
              entrees += tx.montant;
            } else {
              sorties += tx.montant;
            }
            commissions += tx.bonus ?? 0;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Text(
                "Bonjour, ${user?.nom ?? 'Agent'}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // --- Carte du Solde Global (Commissions) ---
              _buildMainBalanceCard(theme, entrees, sorties, commissions),

              const SizedBox(height: 25),

              // --- Mini-Cartes des Puces (Horizontal) ---
              Text("Mes Puces", style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 110, // Légèrement augmenté pour le confort
                child: StreamBuilder<List<AgentNumber>>(
                  stream: pucesStream,
                  builder: (context, puceSnapshot) {
                    final puces = puceSnapshot.data ?? [];
                    if (puces.isEmpty)
                      return const Text("Aucune puce configurée");
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: puces.length,
                      itemBuilder: (context, index) =>
                          _buildMiniPuceCard(puces[index], theme),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // --- Actions Rapides ---
              Text("Actions rapides", style: theme.textTheme.titleMedium),
              const SizedBox(height: 15),
              _buildSyncAction(context, ref, pendingSmsAsync),
              _buildActionButton(
                context: context,
                icon: LucideIcons.plusCircle,
                label: "Saisie manuelle",
                subtitle: "Digitaliser une opération papier",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionView(),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- Mini Historique ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dernières opérations",
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryView(),
                      ),
                    ),
                    child: const Text("Voir tout"),
                  ),
                ],
              ),
              if (transactions.isEmpty)
                const Center(child: Text("Aucune transaction aujourd'hui"))
              else
                ...transactions
                    .take(5)
                    .map((tx) => _buildHistoryLine(tx, theme))
                    .toList(),
            ],
          ),
        );
      },
    );
  }

  // --- COMPOSANTS ---

  Widget _buildMainBalanceCard(
    ThemeData theme,
    double inVal,
    double outVal,
    double comm,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withBlue(180)],
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
        children: [
          const Text(
            "Commissions du jour",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          // Utilisation du Formatter ici
          Text(
            CurrencyFormatter.format(comm),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24, height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                LucideIcons.trendingUp,
                "Entrées",
                CurrencyFormatter.format(inVal),
              ),
              _buildQuickStat(
                LucideIcons.trendingDown,
                "Sorties",
                CurrencyFormatter.format(outVal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPuceCard(AgentNumber puce, ThemeData theme) {
    Color color = _getOpColor(puce.operateur);
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12, bottom: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(LucideIcons.smartphone, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                puce.operateur.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Utilisation du Formatter ici
          Text(
            CurrencyFormatter.format(puce.soldePuce),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            puce.numeroPuce,
            style: TextStyle(
              fontSize: 10,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLine(Transaction tx, ThemeData theme) {
    final bool isRetrait = tx.type == TransactionType.retrait;
    final Color opColor = _getOpColor(tx.operateur);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: opColor.withOpacity(0.1),
        child: Icon(
          isRetrait ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
          size: 18,
          color: opColor,
        ),
      ),
      title: Text(
        tx.nomClient ?? tx.reference,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat('HH:mm').format(tx.horodatage),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        "${isRetrait ? '+' : '-'}${CurrencyFormatter.format(tx.montant)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isRetrait ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  // --- Helpers ---

  Color _getOpColor(OperatorType type) {
    switch (type) {
      case OperatorType.telma:
        return Colors.yellow.shade800;
      case OperatorType.orange:
        return Colors.orange.shade700;
      case OperatorType.airtel:
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncAction(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> pendingSmsAsync,
  ) {
    return _buildActionButton(
      context: context,
      icon: LucideIcons.refreshCw,
      label: "Synchroniser les SMS",
      subtitle: "Détecter les nouvelles transactions",
      trailing: pendingSmsAsync.maybeWhen(
        data: (count) => count > 0
            ? Badge(label: Text('$count'), backgroundColor: Colors.red)
            : const Icon(LucideIcons.chevronRight, size: 18),
        orElse: () => const Icon(LucideIcons.chevronRight, size: 18),
      ),
      onTap: () async {
        if (await Permission.sms.request().isGranted) {
          await ref.read(smsSyncProvider).fetchAndParseSms();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Synchronisation terminée"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        onTap: onTap,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),

        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),

        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),

        trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 18),
      ),
    );
  }
}
