import 'package:flutter/material.dart';
class Flask {
  final String id;
  final String imagePath;
  final Color color;
  final double currentVolume;
  final double maxVolume;
  final String substanceFormula;

  Flask({
    required this.id,
    required this.imagePath,
    required this.color,
    required this.maxVolume,
    this.currentVolume = 0.0,
    this.substanceFormula = '',
  });

  Flask copyWith({
    double? currentVolume,
    String? substanceFormula,
  }) {
    return Flask(
      id: id,
      imagePath: imagePath,
      color: color,
      maxVolume: maxVolume,
      currentVolume: currentVolume ?? this.currentVolume,
      substanceFormula: substanceFormula ?? this.substanceFormula,
    );
  }

  bool get isEmpty => currentVolume <= 0;
  bool get isFull => currentVolume >= maxVolume;
}