class ReactionResult {
  final bool success;
  final String message;
  final Map<String, double> productMasses;
  final Map<String, double> remainingMasses;
  final String? limitingReagent;
  final double efficiency;

  ReactionResult({
    required this.success,
    required this.message,
    required this.productMasses,
    required this.remainingMasses,
    this.limitingReagent,
    this.efficiency = 1.0,
  });

  @override
  String toString() {
    return 'ReactionResult{success: $success, message: $message, efficiency: $efficiency}';
  }
}