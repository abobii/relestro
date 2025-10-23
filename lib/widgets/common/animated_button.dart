import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed; // Сделаем onPressed необязательным
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AnimatedButton({
    super.key,
    this.onPressed, // Теперь может быть null
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        height: 50,
        decoration: BoxDecoration(
          color: isEnabled 
              ? backgroundColor.withOpacity(_isPressed ? 0.8 : 1.0)
              : Colors.grey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled && !_isPressed
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}