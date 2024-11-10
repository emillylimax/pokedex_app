import 'dart:async';
import 'dart:convert';
import 'package:pokedex_app/models/pokeapi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance; //Instancia única - Singleton

  DatabaseHelper._internal();

  static Database? _database;

  //Abertura do banco de dados - Se já existe, reutiliza, se não, cria-se um
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //Inicialização do banco
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pokedex.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS Pokemon');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Pokemon (
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT,
        base TEXT
      )
    ''');
  }

  Future<void> insertDailyEncounter(String id, String name, String type, String base) async {
    final db = await database;
    await db.insert(
      'Pokemon',
      {
        'id': id,
        'name': name,
        'type': type,
        'base': base,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PokeAPI>> getPokemons() async { //Consulta todos pokemons
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Pokemon');

    return List<PokeAPI>.generate(maps.length, (i) {
      return PokeAPI(
        id: maps[i]['id'].toString(),
        name: Name(english: maps[i]['name']),
        type: maps[i]['type'].split(','),
        base: maps[i]['base'] != null ? Base.fromJson(jsonDecode(maps[i]['base'])) : null,
      );
    });
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'pokedex.db');
    await databaseFactory.deleteDatabase(path);
  }

  Future<void> insertPokemon(PokeAPI pokemon) async {
    final db = await database;

    await db.insert(
      'Pokemon',
      {
        'id': pokemon.id,
        'name': pokemon.name?.english,
        'type': pokemon.type?.join(','), 
        'base': pokemon.base != null ? jsonEncode(pokemon.base!.toJson()) : null, 
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
