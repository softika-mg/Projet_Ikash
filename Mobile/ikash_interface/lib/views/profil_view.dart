import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikash_interface/widgets/puce_card.dart';
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
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate)
        return true; // On laisse passer si le tel n'a pas de capteur

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

    // RÉCUPÉRATION DES PUCES VIA PROVIDER (Comme sur Agent Homme)
    // On utilise currentAgentId pour que l'agent voit les siennes
    // et que l'admin voit celles du profil qu'il consulte.
    final pucesAsync = ref.watch(agentPucesProvider(currentAgentId));

    if (currentUser == null)
      return const Scaffold(body: Center(child: Text("Reconnectez-vous")));

    final bool isAdmin = currentUser.role == RoleType.admin;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Profil"), centerTitle: true),
      body: StreamBuilder<Profile>(
        stream: db.watchProfile(currentAgentId),
        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final profile = profileSnapshot.data!;

          // Calcul du solde global réactif
          final soldeTotal = pucesAsync.maybeWhen(
            data: (list) => list.fold(0.0, (sum, item) => sum + item.soldePuce),
            orElse: () => 0.0,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(theme, profile, isAdmin),
              const SizedBox(height: 25),

              _buildInfoTile(
                "Statut",
                isAdmin ? "Administrateur" : "Agent",
                isAdmin ? LucideIcons.shieldCheck : LucideIcons.user,
                theme,
              ),

              _buildInfoTile(
                "Solde Global",
                CurrencyFormatter.format(soldeTotal),
                LucideIcons.wallet,
                theme,
                valueColor: Colors.green,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),

              // --- SECTION TITRE + BOUTON AJOUTER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "MES PUCES DE TRAVAIL",
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.hintColor,
                    ),
                  ),
                  if (isAdmin)
                    TextButton.icon(
                      onPressed: () => _showEditNumberDialog(context, null),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text("Ajouter"),
                    ),
                ],
              ),
              const SizedBox(height: 15),

              // --- AFFICHAGE DES PUCES (RÉACTIF) ---
              pucesAsync.when(
                data: (puces) => puces.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: puces.length,
                        itemBuilder: (context, index) {
                          final puce = puces[index];
                          return PuceCard(
                            puce: puce,
                            canEdit: isAdmin, // Affiche le cadenas ouvert/fermé
                            onTap: isAdmin
                                ? () async {
                                    // Seul l'admin déclenche l'auth + dialogue
                                    bool auth = await _authenticateAdmin();
                                    if (auth && context.mounted)
                                      _showEditNumberDialog(context, puce);
                                  }
                                : null, // L'agent ne peut pas cliquer
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Erreur : $e")),
              ),
            ],
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
            child: Icon(
              isAdmin ? LucideIcons.shieldCheck : LucideIcons.user,
              size: 50,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.nom.isEmpty ? "Utilisateur" : profile.nom,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- CARTE PUCE (DYNAMIQUE) ---
  Widget _buildPuceCard(AgentNumber puce, ThemeData theme, bool isAdmin) {
    // 1. Détermination de la couleur (stoppe le crash si la donnée en base est mal formatée)
    Color cardColor;
    try {
      cardColor = Color(int.parse(puce.color ?? ""));
    } catch (_) {
      cardColor = _getOpColor(puce.operateur);
    }

    return InkWell(
      // Si PAS admin, on met onTap à null -> Aucune réaction au clic, lecture seule
      onTap: isAdmin
          ? () async {
              bool authenticated = await _authenticateAdmin();
              if (authenticated && context.mounted) {
                _showEditNumberDialog(context, puce);
              }
            }
          : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isAdmin
                ? cardColor.withOpacity(0.4)
                : cardColor.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo de l'opérateur (Visuel pro)
                Icon(LucideIcons.smartphone, color: cardColor, size: 22),

                // Indicateur de statut pour l'agent
                Icon(
                  isAdmin ? LucideIcons.unlock : LucideIcons.lock,
                  size: 14,
                  color: cardColor.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(puce.soldePuce),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: cardColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  puce.numeroPuce,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.labelSmall?.color?.withOpacity(0.7),
                  ),
                ),
                // Petit badge du nom de l'opérateur
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    puce.operateur.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ),
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
    final soldeController = TextEditingController(
      text: puce?.soldePuce.toInt().toString(),
    );
    OperatorType selectedOp = puce?.operateur ?? OperatorType.telma;
    Color selectedColor = Color(
      int.tryParse(puce?.color ?? "") ?? _getOpColor(selectedOp).value,
    );

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
                    items: OperatorType.values
                        .map(
                          (op) => DropdownMenuItem(
                            value: op,
                            child: Text(op.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setDState(() => selectedOp = val!),
                    decoration: const InputDecoration(labelText: "Opérateur"),
                  ),
                TextField(
                  controller: numController,
                  decoration: const InputDecoration(labelText: "N° de ligne"),
                ),
                TextField(
                  controller: soldeController,
                  decoration: const InputDecoration(labelText: "Solde initial"),
                ),
                const SizedBox(height: 20),

                // SÉLECTEUR DE COULEUR
                const Text(
                  "Couleur personnalisée",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _pickerColors
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setDState(() => selectedColor = c),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: c,
                            child: selectedColor == c
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Ici, on enregistre la couleur en version Hexadécimale (String) ou Int
                final db = ref.read(databaseProvider);
                await db.saveAgentNumber(
                  AgentNumbersCompanion(
                    id: puce != null
                        ? d.Value(puce.id)
                        : const d.Value.absent(),
                    profileId: d.Value(currentAgentId),
                    operateur: d.Value(selectedOp),
                    numeroPuce: d.Value(numController.text),
                    soldePuce: d.Value(
                      double.tryParse(soldeController.text) ?? 0,
                    ),
                    color: d.Value(
                      selectedColor.value.toString(),
                    ), // Sauvegarde de la couleur !
                  ),
                );
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

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: valueColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() =>
      const Center(child: Text("Aucune puce configurée."));
}
