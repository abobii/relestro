class Quest {
  final int questId;
  final String title;
  final String description;
  final int targetSubstanceId;
  final double targetAmount;
  final String availableReagents;
  final int rewardPoints;

  Quest({
    required this.questId,
    required this.title,
    required this.description,
    required this.targetSubstanceId,
    required this.targetAmount,
    required this.availableReagents,
    required this.rewardPoints,
  });

  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      questId: map['quest_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      targetSubstanceId: map['target_substance_id'] as int,
      targetAmount: (map['target_amount'] as num).toDouble(),
      availableReagents: map['available_reagents'] as String,
      rewardPoints: map['reward_points'] as int,
    );
  }

  List<int> getAvailableReagentIds() {
    return availableReagents.split(',').map((id) => int.parse(id)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'quest_id': questId,
      'title': title,
      'description': description,
      'target_substance_id': targetSubstanceId,
      'target_amount': targetAmount,
      'available_reagents': availableReagents,
      'reward_points': rewardPoints,
    };
  }
}