import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex_app/consts/consts_api.dart';
import 'package:pokedex_app/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:pokedex_app/models/pokeapi.dart';
import 'dart:io'; // Para a verificação de internet

//Gerencia lógica de negócios e dados, incluindo comunicação com a API e os de armazenmento local

//Classe com ChangeNotifier, permite notificação de mudanças para os widgets
class PokeApiProvider with ChangeNotifier {
  List<PokeAPI>? _pokemonList; //Carrega a lista de pokemons

  final DatabaseHelper _databaseHelper = DatabaseHelper(); //Acessa/manipula o banco de dados local --> Lembrar de mostrar

  List<PokeAPI> _allPokemons = []; //Armazena os pokemons em lista, possibilitando paginar
  int _currentPage = 0; 

  final int _limit = 20;
  
  List<PokeAPI>? get pokemonList => _pokemonList; //Acessa a lista
  
  List<PokeAPI> capturedPokemons = []; //Armazena os pokemons capturados

  bool get hasLocalData => _pokemonList != null && _pokemonList!.isNotEmpty; //Confere se há dados locais carregados
  
  //Carrega os pokemons capturados do armazenamento local
  Future<void> loadCapturedPokemons() async {
    final prefs = await SharedPreferences.getInstance(); //Acessa armazenamento
    
    final capturedPokemonsCount = prefs.getInt('capturedPokemonsCount') ?? 0; //Contagem de capturados

    capturedPokemons.clear(); //Limpa lista antes de carregar novos, pra não duplicar dados

    // Percorre a lista de capturados e carrega do armazenamento local
    for (int i = 0; i < capturedPokemonsCount; i++) {
      final pokemonId = prefs.getString('capturedPokemonId_$i');
      
      // Busca cada pelo ID
      if (pokemonId != null) {
        final pokemon = await fetchPokemonById(pokemonId);
        if (pokemon != null) {
          capturedPokemons.add(pokemon);
        }
      }
    }
    notifyListeners(); //Avisa aos widgets
  }

  //Busca API usando o ID
  Future<PokeAPI?> fetchPokemonById(String id) async {
    try {
      //Requisição HTTP usando o ID
      final response = await http.get(Uri.parse('${ConstsAPI.pokeapiURL}/$id'));
      
      //Se deu certo, decodifica JSON e retorna o pokemon, se não, mensagem de erro
      if (response.statusCode == 200) {
        return PokeAPI.fromJson(jsonDecode(response.body));
      } else {
        print("Erro ao buscar Pokémon por ID: ${response.statusCode}");
      }
    } catch (error) {
      print("Erro ao buscar Pokémon: $error");
    }
    return null;
  }

  //Verifica se a internet está disponível
  Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  //Busca a lista de Pokémon da API com suporte à paginação (usando a variável `pageKey`)
  Future<void> fetchPokemonList({int pageKey = 0}) async {
    try {
      //Tenta carregar os armazenados no banco de dados local
      final cachedPokemons = await _databaseHelper.getPokemons();
      
      //Se houver Pokémon no banco local, carrega e notifica
      if (cachedPokemons.isNotEmpty) {
        _pokemonList = cachedPokemons;
        notifyListeners();
        return;
      }

      //Verifica se há conexão com a internet
      final isOnline = await isInternetAvailable();
      if (!isOnline) {
        print('Sem conexão com a internet. Carregando dados locais...');
        
        //Se não houver conexão nem dados locais, informa que não há Pokémon
        if (cachedPokemons.isEmpty) {
          print('Nenhum Pokémon encontrado localmente.');
        }
        return;
      }

      //Se os dados ainda não foram carregados, faz uma requisição para obter todos
      if (_allPokemons.isEmpty) {
        final response = await http.get(Uri.parse(ConstsAPI.pokeapiURL));
        
        //Se a resposta da API for bem-sucedida, decodifica e armazena os dados
        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body);
          _allPokemons = jsonList.map((item) => PokeAPI.fromJson(item)).toList();

          //Salva os recebidos no banco de dados local
          for (var pokemon in _allPokemons) {
            await _databaseHelper.insertPokemon(pokemon);
          }
        } else {
          print("Erro ao buscar Pokémon da API: ${response.statusCode}");
        }
      }

      //Calcula o intervalo de pokemons
      int startIndex = _currentPage * _limit;
      int endIndex = startIndex + _limit;
      
      //Verifica se o índice final ultrapassa o tamanho da lista
      if (endIndex > _allPokemons.length) {
        endIndex = _allPokemons.length;
      }

      //Extrai a lista parcial para a página atual
      _pokemonList = _allPokemons.sublist(startIndex, endIndex);

      _currentPage++; //Incrementa a página atual
      notifyListeners(); //Notifica

    } catch (error) {
      print("Erro ao buscar Pokémon: $error");
    }
  }
}
