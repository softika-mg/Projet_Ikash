import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' as d;
import '../database/app_database.dart';
import '../models/enum.dart';
import '../core/utils/formatters.dart';
import '../services/auth_service.dart';
 import 'package:local_auth/local_auth.dart';

class ProfilView extends ConsumerStatefulWidget {
  const ProfilView({super.key});

  @override
  ConsumerState<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends ConsumerState<ProfilView> {
  int get currentAgentId => ref.read(currentUserProvider)?.id ?? 0;

  final LocalAuthentication auth = LocalAuthentication();

Future<bool> _authenticateAdmin() async {
  try {
    // Vérifie si l'appareil est capable de faire de la biométrie
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

    if (!canAuthenticate) return true; // On laisse passer si le tel n'a pas de capteur

    return await auth.authenticate(
      localizedReason: 'Veuillez vous authentifier pour modifier les puces',
      options: const AuthenticationOptions(
        stickyAuth: true, // Garde l'auth si l'app passe en background
        biometricOnly: true, // Force l'empreinte/faceID (pas de code PIN)
      ),
    );
  } catch (e) {
    return false;
  }
}

  // --- LOGIQUE DE COULEURS PRÉDÉFINIES ---
  final List<Color> _pickerColors = [
    Colors.yellow.shade800,
    Colors.orange.shade700,
    Colors.red.shade700,
    Colors.blue.shade700,
    Colors.green.shade700,
    Colors.purple.shade700,
    Colors.teal.shade700,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Veuillez vous reconnecter")));
    }

    final bool isAdmin = currentUser.role == RoleType.admin;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Profil"), centerTitle: true),
      body: StreamBuilder<Profile>(
        stream: db.watchProfile(currentAgentId),
        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final profile = profileSnapshot.data!;

          return StreamBuilder<List<AgentNumber>>(
            stream: db.watchAgentNumbers(currentAgentId),
            builder: (context, snapshot) {
              final puces = snapshot.data ?? [];
              final soldeTotal = puces.fold(0.0, (sum, item) => sum + item.soldePuce);

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(theme, profile, isAdmin),
                  const SizedBox(height: 25),

                  _buildInfoTile("Statut", isAdmin ? "Administrateur" : "Agent de terrain",
                      isAdmin ? LucideIcons.shieldCheck : LucideIcons.user, theme),

                  _buildInfoTile("Solde Global", CurrencyFormatter.format(soldeTotal),
                      LucideIcons.wallet, theme, valueColor: Colors.green),

                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                  // --- Section Puces avec Gestion des Droits ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("MES PUCES DE TRAVAIL", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                      if (isAdmin && puces.length < 5) // Seul l'admin ajoute
                        TextButton.icon(
                          onPressed: () => _showEditNumberDialog(context, null),
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text("Ajouter"),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (puces.isEmpty) _buildEmptyState()
                  else GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.1,
                    ),
                    itemCount: puces.length,
                    itemBuilder: (context, index) => _buildPuceCard(puces[index], theme, isAdmin),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(ThemeData theme, Profile profile, bool isAdmin) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(isAdmin ? LucideIcons.shieldCheck : LucideIcons.user, size: 50, color: theme.primaryColor),
          ),
          const SizedBox(height: 10),
          Text(profile.nom.isEmpty ? "Utilisateur" : profile.nom, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- CARTE PUCE (DYNAMIQUE) ---
  Widget _buildPuceCard(AgentNumber puce, ThemeData theme, bool isAdmin) {
    // Si tu n'as pas encore la colonne couleur en base, on garde le fallback par opérateur
    // Mais ici, on imagine que puce.color (int) existe
    final Color cardColor = Color(int.tryParse(puce.color ?? "") ?? _getOpColor(puce.operateur).value);

    return InkWell(
      onTap: isAdmin ? () async {
  // On déclenche l'empreinte digitale
  bool authenticated = await _authenticateAdmin();

  if (authenticated) {
    if (context.mounted) _showEditNumberDialog(context, puce);
  } else {
    // Optionnel : Afficher un petit message si échec
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Authentification échouée")),
    );
  }
} : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cardColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(LucideIcons.smartphone, color: cardColor, size: 24),
                if (isAdmin) Icon(LucideIcons.lock, size: 12, color: cardColor.withOpacity(0.5)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(CurrencyFormatter.format(puce.soldePuce), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cardColor)),
                Text(puce.numeroPuce, style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGUE DE MODIFICATION (ADMIN SEULEMENT) ---
  void _showEditNumberDialog(BuildContext context, AgentNumber? puce) {
    final numController = TextEditingController(text: puce?.numeroPuce);
    final soldeController = TextEditingController(text: puce?.soldePuce.toInt().toString());
    OperatorType selectedOp = puce?.operateur ?? OperatorType.telma;
    Color selectedColor = Color(int.tryParse(puce?.color ?? "") ?? _getOpColor(selectedOp).value);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          title: Text(puce == null ? "Nouvelle Puce" : "Paramètres Puce"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (puce == null)
                  DropdownButtonFormField<OperatorType>(
                    value: selectedOp,
                    items: OperatorType.values.map((op) => DropdownMenuItem(value: op, child: Text(op.name.toUpperCase()))).toList(),
                    onChanged: (val) => setDState(() => selectedOp = val!),
                    decoration: const InputDecoration(labelText: "Opérateur"),
                  ),
                TextField(controller: numController, decoration: const InputDecoration(labelText: "N° de ligne")),
                TextField(controller: soldeController, decoration: const InputDecoration(labelText: "Solde initial")),
                const SizedBox(height: 20),

                // SÉLECTEUR DE COULEUR
                const Text("Couleur personnalisée", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _pickerColors.map((c) => GestureDetector(
                    onTap: () => setDState(() => selectedColor = c),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: c,
                      child: selectedColor == c ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                  )).toList(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                // Ici, on enregistre la couleur en version Hexadécimale (String) ou Int
                final db = ref.read(databaseProvider);
                await db.saveAgentNumber(AgentNumbersCompanion(
                  id: puce != null ? d.Value(puce.id) : const d.Value.absent(),
                  profileId: d.Value(currentAgentId),
                  operateur: d.Value(selectedOp),
                  numeroPuce: d.Value(numController.text),
                  soldePuce: d.Value(double.tryParse(soldeController.text) ?? 0),
                  color: d.Value(selectedColor.value.toString()), // Sauvegarde de la couleur !
                ));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  // Fallback couleur par défaut si pas de couleur choisie
  Color _getOpColor(OperatorType type) {
    if (type == OperatorType.telma) return Colors.yellow.shade800;
    if (type == OperatorType.orange) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  Widget _buildInfoTile(String label, String value, IconData icon, ThemeData theme, {Color? valueColor}) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: valueColor)),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("Aucune puce configurée."));
}
