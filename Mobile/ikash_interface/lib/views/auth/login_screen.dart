import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _obscureCode = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // Simulation de login - En prod, appel API ici
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppStrings
        .translations['mg']!; // Assure-toi que les clés correspondent aux nouveaux textes

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Image de fond en bas (bâtiment avec vague bleue)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bottom_building_wave.png', // Exporte depuis Figma ou remplace par ton asset réel
              fit: BoxFit.cover,
              height: 200, // Ajuste pour matcher le design
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 120,
                    ), // Espace en haut pour un aspect aéré
                    // Titre principal
                    Text(
                      'Hiditra amin\'ny kaonty !', // Texte exact du design
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentBlue, // Bleu foncé du design
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Champ Laharan'ny finday
                    _buildLabel('Laharan\'ny finday'),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: '034 -- -- ---',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.accentBlue,
                            width: 1.5,
                          ),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ampidiro ny laharan\'ny finday';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Champ Kaody
                    _buildLabel('Kaody'),
                    TextFormField(
                      controller: _codeController,
                      obscureText: _obscureCode,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.accentBlue,
                            width: 1.5,
                          ),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCode
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[600],
                          ),
                          onPressed: () =>
                              setState(() => _obscureCode = !_obscureCode),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ampidiro ny kaody';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Bouton Hiditra
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppTheme.accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Hiditra',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lien d'inscription
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigue vers écran d'inscription (à implémenter)
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Toy manana kaonty ? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Hisoratra anarana +',
                                style: TextStyle(
                                  color: AppTheme.accentBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 100,
                    ), // Espace pour le fond bleu sans chevauchement
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}
