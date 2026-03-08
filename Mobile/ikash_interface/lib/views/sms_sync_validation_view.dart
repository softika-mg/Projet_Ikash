import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikash_interface/models/enum.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../services/sms_sync_service.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';

class SmsSyncValidationView extends ConsumerStatefulWidget {
  const SmsSyncValidationView({super.key});

  @override
  ConsumerState<SmsSyncValidationView> createState() =>
      _SmsSyncValidationViewState();
}

class _SmsSyncValidationViewState extends ConsumerState<SmsSyncValidationView> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Validation SMS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<SmsReceivedData>>(
        // On ne regarde que les SMS non traités
        stream: db.watchAllPendingSms(),
        builder: (context, snapshot) {
          final pendingSms = snapshot.data ?? [];

          if (pendingSms.isEmpty) {
            return const Center(
              child: Text("Aucune nouvelle transaction détectée."),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingSms.length,
                  itemBuilder: (context, index) {
                    final sms = pendingSms[index];
                    return _buildSmsPreviewCard(sms, theme);
                  },
                ),
              ),
              _buildFooter(pendingSms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSmsPreviewCard(SmsReceivedData sms, ThemeData theme) {
    final isDepot = sms.type == TransactionType.depot;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isDepot ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
          color: isDepot ? Colors.red : Colors.green,
        ),
        title: Text(
          "${sms.operateur.name.toUpperCase()} - ${CurrencyFormatter.format(sms.montant)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Réf: ${sms.reference}"),
        trailing: const Icon(
          LucideIcons.checkCircle,
          color: Colors.blue,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFooter(List<SmsReceivedData> smsList) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : () => _processAll(smsList),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(LucideIcons.save),
          label: Text("COMPARER ET ENREGISTRER (${smsList.length})"),
        ),
      ),
    );
  }

  Future<void> _processAll(List<SmsReceivedData> smsList) async {
    setState(() => _isProcessing = true);

    try {
      final syncService = ref.read(smsSyncProvider);

      for (var sms in smsList) {
        // Appelle ta méthode de réconciliation qu'on a codée plus haut
        await syncService.validateSmsAsTransaction(sms);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${smsList.length} transactions synchronisées !"),
          ),
        );
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
