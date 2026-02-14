import 'package:flutter/material.dart';
import './login_screen.dart';

class AuthStepperView extends StatefulWidget {
  const AuthStepperView({super.key});

  @override
  State<AuthStepperView> createState() => _AuthStepperViewState();
}

class _AuthStepperViewState extends State<AuthStepperView> {
  int _currentStep = 0;

  // Pour l'instant on garde une seule "page" d'accueil comme sur ton design
  // Tu pourras facilement rajouter d'autres steps plus tard
  final List<Map<String, dynamic>> _screens = [
    {
      "title": "Salama !",
      "subtitle": "Ny mpiara-miasa mahatoky ho an'ny Cash Point-nao !",
      "buttonText": "Hanolohy",
    },
    // Tu pourras ajouter d'autres écrans ici plus tard
  ];

  // Chemins des images (remplace par tes assets réels)
  final List<String> _images = [
    'assets/images/onboarding1.png', // enfant / téléphone / etc.
    'assets/images/onboarding2.png',
    'assets/images/onboarding3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final screen = _screens[_currentStep];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenu principal
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Zone haute (optionnel : skip)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        "Passer",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Grand titre "Salama !"
                        Text(
                          screen["title"],
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFF1E3A8A,
                            ), // Bleu foncé style Madagascar
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sous-titre
                        Text(
                          screen["subtitle"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),

                // Espace pour le bouton + marge basse
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          _finishOnboarding, // Pour l'instant une seule page
                      child: Text(
                        screen["buttonText"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Blob / vague décorative en bas + images superposées
            //Positioned(
            //  bottom: 0,
            //  left: 0,
            //  right: 0,
            //  height: 260,
            //  child: Stack(
            //    children: [
            //      // Fond bleu doux / blob
            //      CustomPaint(
            //        size: const Size(double.infinity, 260),
            //        painter: BottomBlobPainter(),
            //      ),

            //      // Images circulaires superposées (en bas à droite)
            //      Positioned(
            //        bottom: 40,
            //        right: 40,
            //        child: Row(
            //          mainAxisSize: MainAxisSize.min,
            //          children: List.generate(_images.length, (i) {
            //            return Padding(
            //              padding: EdgeInsets.only(left: i * 28.0), // chevauchement
            //              child: Container(
            //                width: 100,
            //                height: 100,
            //                decoration: BoxDecoration(
            //                  shape: BoxShape.circle,
            //                  border: Border.all(color: Colors.white, width: 4),
            //                  image: DecorationImage(
            //                    image: AssetImage(_images[i]),
            //                    fit: BoxFit.cover,
            //                  ),
            //                  boxShadow: [
            //                    BoxShadow(
            //                      color: Colors.black.withOpacity(0.15),
            //                      blurRadius: 10,
            //                      offset: const Offset(0, 6),
            //                    ),
            //                  ],
            //                ),
            //              ),
            //            );
            //          }).reversed.toList(), // inverse pour que la dernière soit au-dessus
            //        ),
            //      ),
            //    ],
            //  ),
            //),
          ],
        ),
      ),
    );
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

// Peinture simple pour un effet blob/vague en bas
class BottomBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
          .withOpacity(0.18) // bleu très clair
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.55,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75,
      size.width,
      size.height * 0.45,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
