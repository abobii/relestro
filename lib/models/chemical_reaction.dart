class ChemicalReaction {
  final int reactionId;
  final String reactionString;
  final String reactants;
  final String products;
  final String balancedCoefficients;

  ChemicalReaction({
    required this.reactionId,
    required this.reactionString,
    required this.reactants,
    required this.products,
    required this.balancedCoefficients,
  });

  factory ChemicalReaction.fromMap(Map<String, dynamic> map) {
    return ChemicalReaction(
      reactionId: map['reaction_id'] as int,
      reactionString: map['reaction_string'] as String,
      reactants: map['reactants'] as String,
      products: map['products'] as String,
      balancedCoefficients: map['balanced_coefficients'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reaction_id': reactionId,
      'reaction_string': reactionString,
      'reactants': reactants,
      'products': products,
      'balanced_coefficients': balancedCoefficients,
    };
  }
}