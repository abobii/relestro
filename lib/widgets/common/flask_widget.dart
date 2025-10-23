import 'package:flutter/material.dart';
import '../../models/flask.dart';
import '../../utils/color_palette.dart';

class FlaskWidget extends StatelessWidget {
  final Flask flask;
  final VoidCallback? onTap; // Сделаем onTap необязательным
  final bool isSelected;

  const FlaskWidget({
    super.key,
    required this.flask,
    this.onTap, // Теперь может быть null
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Теперь это нормально, так как onTap может быть null
      child: Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppColors.secondary, width: 3)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Flask body
            Container(
              width: 60,
              height: 100,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
            // Liquid
            if (flask.currentVolume > 0)
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                height: (flask.currentVolume / flask.maxVolume) * 80,
                child: Container(
                  decoration: BoxDecoration(
                    color: flask.color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            // Flask neck
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(left: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}