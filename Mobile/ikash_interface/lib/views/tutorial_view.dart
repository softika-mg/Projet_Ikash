import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TutorialView extends StatefulWidget {
  const TutorialView({super.key});

  @override
  State<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur avec une vidéo de démo (MVola)
    _controller = YoutubePlayerController.fromVideoId(
      videoId: '2Zcq6435CpE', // Remplace par l'ID de ta vidéo YouTube
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
      ),
    );
  }

  @override
  void dispose() {
    // Très important : libérer les ressources quand on quitte la page
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Guide d'utilisation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Vidéo ---
            Text(
              "Tutoriel Vidéo",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Le vrai lecteur YouTube
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),

            const SizedBox(height: 32),

            // --- Section Étapes ---
            Text(
              "Comment ça marche ?",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildStep(
              number: "1",
              title: "Configurez vos puces",
              description:
                  "Allez dans votre Profil et enregistrez vos numéros Telma, Orange et Airtel pour activer le suivi automatique.",
              icon: LucideIcons.smartphone,
              theme: theme,
            ),
            _buildStep(
              number: "2",
              title: "Enregistrez une transaction",
              description:
                  "Utilisez le bouton '+' sur l'accueil. L'application déduira automatiquement le montant du solde de la puce concernée.",
              icon: LucideIcons.plusCircle,
              theme: theme,
            ),
            _buildStep(
              number: "3",
              title: "Suivez votre solde",
              description:
                  "Consultez votre Dashboard ou votre Profil pour voir en temps réel l'argent disponible sur chaque puce de travail.",
              icon: LucideIcons.barChart3,
              theme: theme,
            ),
            _buildStep(
              number: "4",
              title: "Gérez les SMS",
              description:
                  "L'application peut lire vos SMS de confirmation pour enregistrer les transactions sans saisie manuelle.",
              icon: LucideIcons.messageSquare,
              theme: theme,
            ),

            const SizedBox(height: 20),

            // Note de bas de page
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.lightbulb,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Astuce : Gardez toujours vos soldes à jour pour une comptabilité précise.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
