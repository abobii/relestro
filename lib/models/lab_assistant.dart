class LabAssistant {
  final String name;
  final String imagePath;
  final List<String> phrases;
  int currentPhraseIndex = 0;

  LabAssistant({
    required this.name,
    required this.imagePath,
    required this.phrases,
  });

  String get nextPhrase {
    if (phrases.isEmpty) return 'Добро пожаловать в лабораторию!';
    final phrase = phrases[currentPhraseIndex];
    currentPhraseIndex = (currentPhraseIndex + 1) % phrases.length;
    return phrase;
  }
}