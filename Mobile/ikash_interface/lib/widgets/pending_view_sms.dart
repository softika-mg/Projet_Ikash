import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../services/auth_service.dart';

class PendingSmsView extends ConsumerWidget {
  const PendingSmsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On récupère la liste des SMS non traités
    // (Il faudra créer ce StreamProvider dans tes fichiers providers)
    final pendingSmsAsync = ref.watch(allPendingSmsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("SMS à valider")),
      body: pendingSmsAsync.when(
        data: (smsList) => smsList.isEmpty
            ? const Center(child: Text("Aucun nouveau SMS détecté"))
            : ListView.builder(
                itemCount: smsList.length,
                itemBuilder: (context, index) {
                  final sms = smsList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        LucideIcons.messageSquare,
                        color: Colors.blue,
                      ),
                      title: Text("${sms.montant} Ar - ${sms.type}"),
                      subtitle: Text(
                        "Réf: ${sms.reference}\nDe: ${sms.sender}",
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(smsSyncProvider)
                              .validateSmsAsTransaction(sms);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Transaction validée et solde mis à jour !",
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text("Valider"),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Erreur: $e")),
      ),
    );
  }
}
