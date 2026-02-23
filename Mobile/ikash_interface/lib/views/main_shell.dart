import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_service.dart';
import '../models/enum.dart';
import '../widgets/agent_home.dart';
import 'history_view.dart';
import 'stats_view.dart';
import 'admin_dashboard.dart';
import 'admin_logs_view.dart';
import '../providers/theme_provider.dart';
import 'login_page.dart';
import 'profil_view.dart';
import 'setting_view.dart';
import 'about_view.dart';
import 'tutorial_view.dart';
import 'tarif_admin_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider);

    if (user == null) return const Scaffold();

    final bool isAdmin = user.role == RoleType.admin;

    final List<Widget> pages = isAdmin
        ? [const AdminDashboard(), const AdminLogsView()]
        : [const AgentHome(), const HistoryView(), const StatsView()];

    return Scaffold(
      key: _scaffoldKey,
      extendBody: false, // Permet au contenu de passer sous la barre flottante
      appBar: AppBar(
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: CircleAvatar(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: Text(
                user.nom[0].toUpperCase(),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          isAdmin ? "Console Admin" : "iKash Mobile",
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          // --- Bouton de Changement de Thème Animé ---
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                  key: ValueKey<bool>(isDarkMode),
                  color: isDarkMode ? Colors.orangeAccent : Colors.indigo,
                ),
              ),
            ),
          ),
        ],
        centerTitle: false,
      ),

      // --- Drawer ---
      drawer: _buildModernDrawer(context, user, theme, isAdmin),

      // --- Body ---
      body: pages[_currentIndex],

      // --- Barre de Navigation Flottante ---
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.cardColor, // S'adapte au mode sombre/clair
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            itemPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            items: isAdmin ? _buildAdminItems(theme) : _buildAgentItems(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer(
    BuildContext context,
    user,
    ThemeData theme,
    bool isAdmin,
  ) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.nom[0],
                style: TextStyle(
                  fontSize: 24,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              user.nom,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              user.role == RoleType.admin
                  ? "Administrateur"
                  : "Solde : ${user.soldeCourant.toStringAsFixed(2)} Ar", // Affichage du solde
            ),
          ),
          // --- Section Mon Compte ---
          ListTile(
            leading: const Icon(LucideIcons.user, color: Colors.blue),
            title: const Text("Mon Profil"),
            subtitle: const Text("Gérer mes puces et mon solde"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilView()),
            ),
          ),
          ListTile(
            leading: Icon(
              isAdmin ? LucideIcons.database : LucideIcons.list,
              color: Colors.orange,
            ),
            title: const Text("Grille Tarifaire"),
            subtitle: Text(
              isAdmin
                  ? "Consulter et modifier les tarifs"
                  : "Consulter les frais de transaction",
            ),
            onTap: () {
              Navigator.pop(context); // Ferme le drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TarifAdminScreen()),
              );
            },
          ),

          // --- Section Aide & Guide ---
          ListTile(
            leading: const Icon(LucideIcons.bookOpen, color: Colors.green),
            title: const Text("Guide d'utilisation"),
            subtitle: const Text("Apprendre à utiliser l'application"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TutorialView()),
            ),
          ),

          const Divider(), // Une petite ligne de séparation pour la clarté
          // --- Section Configuration ---
          ListTile(
            leading: const Icon(LucideIcons.settings),
            title: const Text("Paramètres"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsView()),
            ),
          ),

          // --- Section Informations ---
          ListTile(
            leading: const Icon(LucideIcons.helpCircle),
            title: const Text("À propos"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutView()),
            ),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(LucideIcons.power, color: Colors.red),
            title: const Text(
              "Déconnexion",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.pop(context); // Ferme le drawer

              // Maintenant c'est un Future, donc le await est autorisé
              await ref.read(authServiceProvider).logout();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<SalomonBottomBarItem> _buildAgentItems(ThemeData theme) {
    return [
      SalomonBottomBarItem(
        icon: const Icon(LucideIcons.home),
        title: const Text("Accueil"),
        selectedColor: theme.primaryColor,
      ),
      SalomonBottomBarItem(
        icon: const Icon(LucideIcons.history),
        title: const Text("Historique"),
        selectedColor: theme.primaryColor,
      ),
      SalomonBottomBarItem(
        icon: const Icon(LucideIcons.pieChart),
        title: const Text("Rapports"),
        selectedColor: Colors.teal,
      ),
    ];
  }

  List<SalomonBottomBarItem> _buildAdminItems(ThemeData theme) {
    return [
      SalomonBottomBarItem(
        icon: const Icon(LucideIcons.layoutDashboard),
        title: const Text("Stats"),
        selectedColor: Colors.indigo,
      ),
      SalomonBottomBarItem(
        icon: const Icon(LucideIcons.clipboardList),
        title: const Text("Logs"),
        selectedColor: Colors.indigo,
      ),
    ];
  }
}
