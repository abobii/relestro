class Substance {
  final int substanceId;
  final String name;
  final String formula;
  final double molarMass;
  final String description;

  Substance({
    required this.substanceId,
    required this.name,
    required this.formula,
    required this.molarMass,
    required this.description,
  });

  factory Substance.fromMap(Map<String, dynamic> map) {
    return Substance(
      substanceId: map['substance_id'] as int,
      name: map['name'] as String,
      formula: map['formula'] as String,
      molarMass: (map['molar_mass'] as num).toDouble(),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'substance_id': substanceId,
      'name': name,
      'formula': formula,
      'molar_mass': molarMass,
      'description': description,
    };
  }
}