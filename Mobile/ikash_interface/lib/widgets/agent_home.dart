import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/app_database.dart';
import '../services/auth_service.dart';
import '../views/add_transaction_view.dart';
import '../services/sms_sync_service.dart';
import '../models/enum.dart';
import '../views/history_view.dart';
import '../views/transaction_details_view.dart'; // Importation de notre nouvelle vue
import '../core/utils/formatters.dart';
import '../views/sms_sync_validation_view.dart';

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
    final puces = ref.watch(agentNumbersStreamProvider).value ?? [];

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
              // --- Salutations chaleureuses et personnalisées ---
              Text(
                "Ravi de vous retrouver, ${user?.nom ?? 'partenaire'}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Voici le point sur vos activités d'aujourd'hui",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 25),

              // --- Tableau de bord : Valorisation du travail ---
              _buildMainBalanceCard(theme, entrees, sorties, commissions),

              const SizedBox(height: 30),

              // --- Section Puces : État du matériel de travail ---
              Row(
                children: [
                  Icon(
                    LucideIcons.smartphone,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Vos puces de transaction",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 115,
                child: StreamBuilder<List<AgentNumber>>(
                  stream: pucesStream,
                  builder: (context, puceSnapshot) {
                    final pucesList = puceSnapshot.data ?? [];
                    if (pucesList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.disabledColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            "Aucune puce n'est configurée pour le moment.",
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pucesList.length,
                      itemBuilder: (context, index) =>
                          _buildMiniPuceCard(pucesList[index], theme),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // --- Espace d'action ---
              Text(
                "Que souhaitez-vous faire ?",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildSyncAction(context, ref, pendingSmsAsync),
              _buildActionButton(
                context: context,
                icon: LucideIcons.filePlus,
                label: "Enregistrer une opération manuelle",
                subtitle:
                    "Pour ajouter un transfert depuis votre cahier papier",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionView(),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- Section Flux d'activité ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.history,
                        size: 18,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Vos derniers mouvements",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryView(),
                      ),
                    ),
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text("Tout voir"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (transactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      "Aucune transaction n'a encore été enregistrée aujourd'hui.",
                      style: TextStyle(
                        color: theme.hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...transactions
                    .take(5)
                    .map((tx) => _buildHistoryLine(context, tx, theme, puces))
                    .toList(),
            ],
          ),
        );
      },
    );
  }

  // --- COMPOSANTS INTERACTIFS ET HUMAINS ---

  Widget _buildMainBalanceCard(
    ThemeData theme,
    double inVal,
    double outVal,
    double comm,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withBlue(160)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.award, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text(
                "Vos gains cumulés aujourd'hui",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            CurrencyFormatter.format(comm),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const Divider(color: Colors.white24, height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                LucideIcons.arrowDownLeft,
                "Total des retraits",
                CurrencyFormatter.format(inVal),
              ),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildQuickStat(
                LucideIcons.arrowUpRight,
                "Total des dépôts",
                CurrencyFormatter.format(outVal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPuceCard(AgentNumber puce, ThemeData theme) {
    final colorValue = int.tryParse(puce.color ?? "");
    final Color color = colorValue != null ? Color(colorValue) : Colors.grey;

    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12, bottom: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                puce.operateur.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(puce.soldePuce),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            puce.numeroPuce,
            style: TextStyle(
              fontSize: 11,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLine(
    BuildContext context,
    Transaction tx,
    ThemeData theme,
    List<AgentNumber> puces,
  ) {
    final bool isRetrait = tx.type == TransactionType.retrait;
    Color opColor;

    try {
      final puceIdoine = puces.firstWhere((p) => p.operateur == tx.operateur);
      if (puceIdoine.color != null && puceIdoine.color!.isNotEmpty) {
        opColor = Color(int.parse(puceIdoine.color!));
      } else {
        opColor = _getOpColor(tx.operateur);
      }
    } catch (e) {
      opColor = _getOpColor(tx.operateur);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: ListTile(
        onTap: () {
          // Connexion naturelle avec le nouvel écran de détails interactif
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailView(
                transaction: tx,
                operatorColor: opColor,
              ),
            ),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: opColor.withOpacity(0.1),
          child: Icon(
            isRetrait ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
            size: 18,
            color: opColor,
          ),
        ),
        title: Text(
          tx.nomClient?.isNotEmpty == true
              ? tx.nomClient!
              : "Client non enregistré",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "Enregistré à ${DateFormat('HH:mm').format(tx.horodatage)}",
          style: TextStyle(fontSize: 12, color: theme.hintColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${isRetrait ? '+' : '-'}${CurrencyFormatter.format(tx.montant)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isRetrait ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: theme.hintColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

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
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
      label: "Relever la boîte de réception SMS",
      subtitle: "Vérifier et ajouter automatiquement les transferts reçus",
      trailing: pendingSmsAsync.maybeWhen(
        data: (count) => count > 0
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$count en attente",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Theme.of(context).hintColor,
              ),
        orElse: () => Icon(
          LucideIcons.chevronRight,
          size: 18,
          color: Theme.of(context).hintColor,
        ),
      ),
      onTap: () async {
        if (await Permission.sms.request().isGranted) {
          await ref.read(smsSyncProvider).fetchAndParseSms();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SmsSyncValidationView(),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.08),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
        ),
        trailing:
            trailing ??
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: Theme.of(context).hintColor,
            ),
      ),
    );
  }
}
