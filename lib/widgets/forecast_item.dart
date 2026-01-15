import 'package:flutter/material.dart';

class ForecastItem extends StatelessWidget {
  final String time;
  final String iconCode;
  final int temp;

  const ForecastItem({
    super.key,
    required this.time,
    required this.iconCode,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(4), // Little bit of rounding
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // We can use a network image for the icon, or map it to assets if we had them.
          // For now, let's use the network image from OpenWeatherMap but style it.
          // Or even better, just an icon for simplicity if we want "pixel" look,
          // but typically we load the icon from URL.
          Image.network(
            'https://openweathermap.org/img/wn/$iconCode.png',
            width: 40,
            height: 40,
            color: Colors.white,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '$temp°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
