class AppConstants {
  static const String appName = 'Химический симулятор';
  static const String appVersion = '1.0.0';
  
  // Цели заданий
  static const double waterTargetMass = 36.04;
  static const double co2TargetMass = 44.01;
  static const double methaneTargetMass = 88.02;
  
  // Награды за задания
  static const int waterReward = 100;
  static const int co2Reward = 150;
  static const int methaneReward = 200;
  
  // Допустимая погрешность
  static const double massTolerance = 0.1;
}

class AssetPaths {
  static const String labAssistant = 'assets/images/lab_assistant.png';
  static const String flaskBlue = 'assets/images/flask_blue.png';
  static const String flaskRed = 'assets/images/flask_red.png';
  static const String flaskGreen = 'assets/images/flask_green.png';
  static const String flaskOrange = 'assets/images/flask_orange.png';
  static const String flaskPurple = 'assets/images/flask_purple.png';
  
  static const String animationReaction = 'assets/animations/reaction_mixing.json';
  static const String animationSuccess = 'assets/animations/success_celebration.json';
  static const String animationPouring = 'assets/animations/flask_pouring.json';
  
  static const String soundSelect = 'assets/sounds/flask_select.wav';
  static const String soundSuccess = 'assets/sounds/reaction_success.wav';
  static const String soundComplete = 'assets/sounds/quest_complete.wav';
}