import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final AnimationController animationController;
  final bool isLoading;
  final String? error;

  const LoadingOverlay({
    super.key,
    required this.animationController,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: FadeTransition(
          opacity: animationController,
          child: const Text(
            'Yükleniyor...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      );
    } else if (error != null) {
      return Center(
        child: Text(
          'Hata: $error',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
