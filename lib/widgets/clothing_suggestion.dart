import 'package:flutter/material.dart';

class ClothingSuggestion extends StatelessWidget {
  final double temp;
  final String weatherMain;

  const ClothingSuggestion({
    super.key,
    required this.temp,
    required this.weatherMain,
  });

  @override
  Widget build(BuildContext context) {
    String suggestion = '';
    IconData icon = Icons.checkroom;

    // Basit bir kıyafet mantığı
    if (temp < 5) {
      suggestion = 'Kalın giyin! Mont, atkı, eldiven şart.';
      icon = Icons.ac_unit;
    } else if (temp < 15) {
      suggestion = 'Hırka veya ceket al. Biraz serin.';
      icon = Icons.layers;
    } else if (temp < 25) {
      suggestion = 'Tişört ve ince bir şeyler iyidir.';
      icon = Icons.wb_sunny;
    } else {
      suggestion = 'Çok sıcak! Şort, ince tişört, bol su.';
      icon = Icons.pool;
    }

    if (weatherMain.toLowerCase().contains('rain')) {
      suggestion += '\nŞemsiyeni unutma!';
      icon = Icons.umbrella;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
        borderRadius: BorderRadius.circular(4), // Pixel art köşeli hissi
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              suggestion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.4,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
