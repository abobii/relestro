import 'package:flutter/material.dart';
import '../../utils/color_palette.dart';
import '../common/animated_button.dart';
import '../particles/success_particles.dart';

class SuccessScreen extends StatelessWidget {
  final String title;
  final String description;
  final int pointsEarned;
  final VoidCallback onContinue;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.description,
    required this.pointsEarned,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Затемнение фона
          Container(color: Colors.black54),
          
          // Анимации частиц
          const SuccessParticles(),
          
          // Контент
          Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Иконка успеха
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.celebration,
                        size: 40,
                        color: AppColors.success,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Заголовок
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Описание
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Награда
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            '+$pointsEarned очков',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Кнопка продолжения
                    AnimatedButton(
                      onPressed: onContinue,
                      child: const Text(
                        'Продолжить',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}