//tarif_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';

// Tes fichiers locaux
import '../models/enum.dart';
import '../services/tarif_service.dart';
import '../database/app_database.dart';
import 'package:local_auth/local_auth.dart'; // Pour l'empreinte
import '../services/auth_service.dart'; // Pour récupérer le rôle


class TarifAdminScreen extends ConsumerWidget {
  const TarifAdminScreen({super.key});
  // Instance pour l'authentification locale
  static final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> _verifierEmpreinte() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true; // On laisse passer si le tel n'a pas de biométrie

      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour modifier les tarifs',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),

      );
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  	final user = ref.watch(currentUserProvider);
    final bool isAdmin = user?.role == RoleType.admin;
    final tarifsAsync = ref.watch(tarifsStreamProvider);
    final formatter = NumberFormat("#,###", "fr_FR");
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Gestion des Tarifs' : 'Grille Tarifaire'),
        centerTitle: true,
      ),
      body: tarifsAsync.when(
        data: (liste) => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: liste.length,
          itemBuilder: (context, index) {
            final t = liste[index];
            final profit = t.fraisClient - t.fraisOperateur;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getOpColor(t.operateur),
                  child: Text(t.operateur.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                ),
                title: Text("${formatter.format(t.montantMin)} - ${formatter.format(t.montantMax)} Ar"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Frais Client: ${formatter.format(t.fraisClient)} Ar"),
                    if (isAdmin) Text("Com. Opérateur: ${formatter.format(t.fraisOperateur)} Ar"),
                  ],
                ),
                trailing: isAdmin
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${formatter.format(profit)} Ar",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text("Gain", style: TextStyle(fontSize: 10)),
                  ],
                )
                : Icon(Icons.info_outline, color: theme.primaryColor.withOpacity(0.5)),

                // --- PROTECTION ICI ---
                onTap: isAdmin ? () async {
                  if (await _verifierEmpreinte()) {
                    _showEditDialog(context, ref, t);
                  }
                } : null,
                onLongPress: isAdmin ? () async {
                   if (await _verifierEmpreinte()) {
                    _confirmDelete(context, ref, t);
                  }
                } : null,
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur: $err")),
      ),

      // Seul l'admin voit le bouton d'ajout
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () async {
          if (await _verifierEmpreinte()) {
            _showEditDialog(context, ref, null);
          }
        },
        label: const Text("Ajouter"),
        icon: const Icon(Icons.add),
      ) : null,
    );
  }

  Color _getOpColor(OperatorType op) {
    switch (op) {
      case OperatorType.telma: return Colors.yellow.shade800;
      case OperatorType.orange: return Colors.orange.shade900;
      case OperatorType.airtel: return Colors.red.shade900;
      default: return Colors.blueGrey;
    }
  }
  void _showEditDialog(BuildContext context, WidgetRef ref, TarifData? tarif) {
  final formKey = GlobalKey<FormState>();

  // Si tarif est null, on est en mode "Ajout", sinon "Modification"
  final minController = TextEditingController(text: tarif?.montantMin.toString() ?? '');
  final maxController = TextEditingController(text: tarif?.montantMax.toString() ?? '');
  final fraisOpController = TextEditingController(text: tarif?.fraisOperateur.toString() ?? '');
  final fraisCliController = TextEditingController(text: tarif?.fraisClient.toString() ?? '');

  OperatorType selectedOp = tarif?.operateur ?? OperatorType.telma; // Valeur par défaut si ajout



  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tarif == null ? "Ajouter un Tarif" : "Modifier le Tarif"),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sélecteur d'opérateur
              DropdownButtonFormField<OperatorType>(
                value: selectedOp,
                decoration: const InputDecoration(labelText: "Opérateur"),
                items: OperatorType.values.map((op) => DropdownMenuItem(
                  value: op,
                  child: Text(op.name.toUpperCase()),
                )).toList(),
                onChanged: (val) => selectedOp = val!,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minController,
                      decoration: const InputDecoration(labelText: "Montant Min", suffixText: "Ar"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: maxController,
                      decoration: const InputDecoration(labelText: "Montant Max", suffixText: "Ar"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: fraisCliController,
                decoration: const InputDecoration(labelText: "Frais payés par le Client", suffixText: "Ar"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: fraisOpController,
                decoration: const InputDecoration(labelText: "Frais pris par l'Opérateur", suffixText: "Ar"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              // Création de l'objet Companion pour Drift
              final entry = TarifsCompanion(
                id: tarif == null ? const Value.absent() : Value(tarif.id),
                operateur: Value(selectedOp),
                montantMin: Value(double.parse(minController.text)),
                montantMax: Value(double.parse(maxController.text)),
                fraisOperateur: Value(double.parse(fraisOpController.text)),
                fraisClient: Value(double.parse(fraisCliController.text)),
                derniereMaj: Value(DateTime.now()),
              );

              await ref.read(tarifServiceProvider).upsertTarif(entry);
              if (ctx.mounted) Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tarif enregistré !"), backgroundColor: Colors.green),
              );
            }
          },
          child: const Text("Enregistrer"),
        ),
      ],
    ),
  );
}

  // --- LOGIQUE DIALOGUE ---
  void _confirmDelete(BuildContext context, WidgetRef ref, TarifData t) {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: const Text("Voulez-vous vraiment supprimer cette tranche ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              ref.read(tarifServiceProvider).supprimerTarif(t.id);
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );
  }
}
