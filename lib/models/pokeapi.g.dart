// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokeapi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokeAPI _$PokeAPIFromJson(Map<String, dynamic> json) => PokeAPI(
      id: json['id'] as String?,
      name: json['name'] == null
          ? null
          : Name.fromJson(json['name'] as Map<String, dynamic>),
      type: (json['type'] as List<dynamic>?)?.map((e) => e as String).toList(),
      base: json['base'] == null
          ? null
          : Base.fromJson(json['base'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokeAPIToJson(PokeAPI instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'base': instance.base,
    };

Name _$NameFromJson(Map<String, dynamic> json) => Name(
      english: json['english'] as String?,
    );

Map<String, dynamic> _$NameToJson(Name instance) => <String, dynamic>{
      'english': instance.english,
    };

Base _$BaseFromJson(Map<String, dynamic> json) => Base(
      hp: (json['HP'] as num).toInt(),
      attack: (json['Attack'] as num).toInt(),
      defense: (json['Defense'] as num).toInt(),
      spAttack: (json['Sp. Attack'] as num).toInt(),
      spDefense: (json['Sp. Defense'] as num).toInt(),
      speed: (json['Speed'] as num).toInt(),
    );

Map<String, dynamic> _$BaseToJson(Base instance) => <String, dynamic>{
      'HP': instance.hp,
      'Attack': instance.attack,
      'Defense': instance.defense,
      'Sp. Attack': instance.spAttack,
      'Sp. Defense': instance.spDefense,
      'Speed': instance.speed,
    };
