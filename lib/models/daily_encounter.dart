class DailyEncounter {
  final int id;
  final int pokemonId;
  final DateTime encounterDate;

  DailyEncounter({
    required this.id,
    required this.pokemonId,
    required this.encounterDate,
  });

// Instancia Encontro Diário a partir do JSON
  factory DailyEncounter.fromJson(Map<String, dynamic> json) {
    return DailyEncounter(
      id: json['id'],
      pokemonId: json['pokemonId'],
      encounterDate: DateTime.parse(json['encounterDate']),
    );
  }

// Converte a instância em MAP
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pokemonId': pokemonId,
      'encounterDate': encounterDate.toIso8601String(),
    };
  }
}
