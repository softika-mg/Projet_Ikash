import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';

class SmsInboxView extends ConsumerWidget {
  const SmsInboxView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Flux SMS Reçus",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.refresh(databaseProvider),
          ),
        ],
      ),
      body: StreamBuilder<List<SmsReceivedData>>(
        stream: db.watchAllSms(), // On utilise la méthode de ta DB
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final allSms = snapshot.data!;
          if (allSms.isEmpty) {
            return const Center(
              child: Text("Aucun SMS dans la base de données"),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allSms.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sms = allSms[index];
              return _buildSmsCard(context, theme, sms);
            },
          );
        },
      ),
    );
  }

  Widget _buildSmsCard(
    BuildContext context,
    ThemeData theme,
    SmsReceivedData sms,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: sms.estTraite
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            sms.estTraite ? LucideIcons.check : LucideIcons.mail,
            color: sms.estTraite ? Colors.green : Colors.grey,
            size: 18,
          ),
        ),
        title: Text(
          "${sms.sender.toUpperCase()} - ${CurrencyFormatter.format(sms.montant)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          "Réf: ${sms.reference} • ${DateFormat('dd MMM, HH:mm').format(sms.dateReception)}",
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TEXTE BRUT DU SMS :",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sms.rawBody,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!sms.estTraite)
                      TextButton.icon(
                        onPressed: () {
                          /* Logique pour forcer le traitement */
                        },
                        icon: const Icon(LucideIcons.play, size: 14),
                        label: const Text("Traiter manuellement"),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
