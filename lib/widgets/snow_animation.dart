import 'dart:math';

import 'package:flutter/material.dart';

class SnowAnimation extends StatefulWidget {
  final Animation<double> animation;

  const SnowAnimation({super.key, required this.animation});

  @override
  State<SnowAnimation> createState() => _SnowAnimationState();
}

class _SnowAnimationState extends State<SnowAnimation> {
  late final List<_Snowflake> _flakes;
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _flakes = List.generate(80, (_) => _buildFlake());
  }

  _Snowflake _buildFlake() {
    return _Snowflake(
      xFraction: _random.nextDouble(),
      size: _random.nextDouble() * 8 + 4, // 4 - 12 px
      speed: _random.nextDouble() * 0.4 + 0.2, // 0.2 - 0.6x (slower than rain)
      phase: _random.nextDouble(),
      swayAmount: _random.nextDouble() * 0.05 + 0.02, // Çok az salınım
      swaySpeed: _random.nextDouble() * 0.5 + 0.3, // Çok yavaş salınım
      opacity: _random.nextDouble() * 0.25 + 0.4, // 0.4 - 0.65
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _SnowPainter(
              progress: widget.animation.value,
              flakes: _flakes,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SnowPainter extends CustomPainter {
  final double progress;
  final List<_Snowflake> flakes;

  _SnowPainter({required this.progress, required this.flakes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final flake in flakes) {
      final dx =
          flake.xFraction * size.width +
          sin((flake.phase + progress * flake.swaySpeed) * 2 * pi) *
              flake.swayAmount *
              size.width;
      final dy =
          ((flake.phase + progress * flake.speed * 10) % 1.0) * size.height;

      paint.color = Colors.white.withOpacity(flake.opacity);

      canvas.drawCircle(Offset(dx, dy), flake.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.flakes != flakes;
  }
}

class _Snowflake {
  final double xFraction;
  final double size;
  final double speed;
  final double phase;
  final double swayAmount;
  final double swaySpeed;
  final double opacity;

  _Snowflake({
    required this.xFraction,
    required this.size,
    required this.speed,
    required this.phase,
    required this.swayAmount,
    required this.swaySpeed,
    required this.opacity,
  });
}
