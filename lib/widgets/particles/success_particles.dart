import 'dart:math';

import 'package:flutter/material.dart';

class SuccessParticles extends StatefulWidget {
  const SuccessParticles({super.key});

  @override
  State<SuccessParticles> createState() => _SuccessParticlesState();
}

class _SuccessParticlesState extends State<SuccessParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(_controller.value),
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double animationValue;

  _ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Простые круги в качестве частиц
    for (int i = 0; i < 10; i++) {
      final angle = 2 * 3.14159 * (i / 10 + animationValue);
      final radius = 50 + 30 * (i % 3);
      final x = size.width / 2 + radius * cos(angle);
      final y = size.height / 2 + radius * sin(angle);
      
      canvas.drawCircle(Offset(x, y), 3 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}