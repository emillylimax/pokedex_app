import 'package:json_annotation/json_annotation.dart';

part 'pokeapi.g.dart';

//Classe pode ser convertida para JSON/Vice-versa
@JsonSerializable()
class PokeAPI {
  String? id;
  Name? name;
  List<String>? type;
  Base? base;

  PokeAPI({this.id, this.name, this.type, this.base});

  factory PokeAPI.fromJson(Map<String, dynamic> json) => _$PokeAPIFromJson(json); //Cria um objeto PokeAPI a partir de um Mapa JSON
  Map<String, dynamic> toJson() => _$PokeAPIToJson(this); //Faz o inverso
}

@JsonSerializable()
class Name {
  String? english;

  Name({this.english});

  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);
  Map<String, dynamic> toJson() => _$NameToJson(this);
}

@JsonSerializable()
class Base {
  //@JsonKey é usada para mapear a chave JSON para um nome de campo Dart
  @JsonKey(name: 'HP')
  final int hp;

  @JsonKey(name: 'Attack') 
  final int attack;

  @JsonKey(name: 'Defense') 
  final int defense;

  @JsonKey(name: 'Sp. Attack')
  final int spAttack;

  @JsonKey(name: 'Sp. Defense')
  final int spDefense;

  @JsonKey(name: 'Speed')
  final int speed;

  Base({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
  });

  factory Base.fromJson(Map<String, dynamic> json) => _$BaseFromJson(json);
  Map<String, dynamic> toJson() => _$BaseToJson(this);
}
