import 'package:flutter/material.dart';
import 'package:soft_support_decktop/theme/colors.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + _scaleController.value * 0.2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
          ),
        );
      },
    );
  }
}

class ListeningIndicator extends StatefulWidget {
  const ListeningIndicator({super.key});

  @override
  State<ListeningIndicator> createState() => _ListeningIndicatorState();
}

class _ListeningIndicatorState extends State<ListeningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialise l'animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Boucle infinie avec effet de retour.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double scale = 1 + (_controller.value * 1.3); // Échelle 1 à 2.3
            return Transform.scale(
              scale: scale,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFD2DEE6),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFFF9D63F), width: 2),
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/logo_circle.png'), // Chemin vers le logo
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// class AnimationExample extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ImageSequenceAnimator(
//           "assets/images/frames", // Chemin du dossier contenant les images
//           "frame_", // Préfixe du nom des images (e.g., frame_1, frame_2)
//           0, // Index de départ
//           10, // Index de fin
//           "png", // Extension des fichiers
//           fps: 24, // Images par seconde
//           isLooping: true, // Animation en boucle
//         ),
//       ),
//     );
//   }
// }
