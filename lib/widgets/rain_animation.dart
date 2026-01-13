import 'dart:math';

import 'package:flutter/material.dart';

class RainAnimation extends StatefulWidget {
  final Animation<double> animation;

  const RainAnimation({super.key, required this.animation});

  @override
  State<RainAnimation> createState() => _RainAnimationState();
}

class _RainAnimationState extends State<RainAnimation> {
  late final List<_Raindrop> _drops;
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _drops = List.generate(120, (_) => _buildDrop());
  }

  _Raindrop _buildDrop() {
    return _Raindrop(
      xFraction: _random.nextDouble(),
      length: _random.nextDouble() * 18 + 10, // 10 - 28 px
      speed: _random.nextDouble() * 0.7 + 0.5, // 0.5 - 1.2x
      phase: _random.nextDouble(),
      thickness: _random.nextDouble() * 0.7 + 0.8, // 0.8 - 1.5 px
      opacity: _random.nextDouble() * 0.15 + 0.15, // 0.15 - 0.30
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _RainPainter(
              progress: widget.animation.value,
              drops: _drops,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  final double progress;
  final List<_Raindrop> drops;

  _RainPainter({required this.progress, required this.drops});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      final dx = drop.xFraction * size.width;
      final dy = ((drop.phase + progress * drop.speed) % 1.0) * size.height;
      final endY = dy + drop.length;

      paint
        ..color = Colors.white.withOpacity(drop.opacity)
        ..strokeWidth = drop.thickness;

      canvas.drawLine(Offset(dx, dy), Offset(dx, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.drops != drops;
  }
}

class _Raindrop {
  final double xFraction;
  final double length;
  final double speed;
  final double phase;
  final double thickness;
  final double opacity;

  _Raindrop({
    required this.xFraction,
    required this.length,
    required this.speed,
    required this.phase,
    required this.thickness,
    required this.opacity,
  });
}
