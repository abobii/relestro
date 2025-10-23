import 'package:flutter/material.dart';

class LiquidAnimation extends StatefulWidget {
  const LiquidAnimation({super.key});

  @override
  State<LiquidAnimation> createState() => _LiquidAnimationState();
}

class _LiquidAnimationState extends State<LiquidAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 1 - _animation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 80,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}