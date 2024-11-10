import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/models/pokeapi.dart';
import 'package:pokedex_app/providers/pokeapi_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CapturePokemonPage extends StatefulWidget {
  @override
  _CapturePokemonPageState createState() => _CapturePokemonPageState();
}

class _CapturePokemonPageState extends State<CapturePokemonPage> {
  PokeAPI? _randomPokemon; //Guarda pokemon que será exibido
  bool _isPokemonCaptured = false;

  @override
  void initState() {
    super.initState();
    _initializeRandomPokemon(); 
  }

  //Carrega pokemon previamente salvo (se houver) da memória local com shared
  Future<void> _initializeRandomPokemon() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPokemonId = prefs.getString('savedPokemonId');
    final savedSelectionTime = prefs.getString('savedSelectionTime');
  //Verifica se tem Pokemon salvo e se é válido
    if (savedPokemonId != null && savedSelectionTime != null) {
      final currentTime = DateTime.now();
      final selectionDateTime = DateTime.parse(savedSelectionTime);

      if (currentTime.isBefore(selectionDateTime.add(Duration(minutes: 1)))) {
        _randomPokemon = await _fetchPokemonById(savedPokemonId);
        if (_randomPokemon != null) {
          setState(() {
            _isPokemonCaptured = prefs.getBool('isPokemonCaptured') ?? false;
          });
          return;
        }
      }
    }
  //Se não for, pega uma nova lista de Pokemons
    final provider = Provider.of<PokeApiProvider>(context, listen: false);
    await provider.fetchPokemonList();
    final random = Random();
    final pokemons = provider.pokemonList;

    if (pokemons != null && pokemons.isNotEmpty) {
      _randomPokemon = pokemons[random.nextInt(pokemons.length)];
      await prefs.setString('savedPokemonId', _randomPokemon!.id.toString());
      await prefs.setString('savedSelectionTime', DateTime.now().toString());
      await prefs.setBool('isPokemonCaptured', _isPokemonCaptured);

      setState(() {
        _isPokemonCaptured = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum Pokémon disponível para captura.')),
      );
    }
  }

  //Verifica total de pokemons capturados (se é menor que 6, se já foi capturado ou não...)
  Future<void> _capturePokemon(String pokemonId) async {
    final prefs = await SharedPreferences.getInstance();
    int capturedCount = prefs.getInt('capturedPokemonsCount') ?? 0;

    if (capturedCount >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você já capturou 6 Pokémon!')),
      );
      return;
    }

    List<String> capturedPokemonIds = [];
    for (int i = 0; i < capturedCount; i++) {
      String? capturedPokemonId = prefs.getString('capturedPokemonId_$i');
      if (capturedPokemonId != null) {
        capturedPokemonIds.add(capturedPokemonId);
      }
    }

    if (capturedPokemonIds.contains(pokemonId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você já capturou este Pokémon!')),
      );
      return;
    }

    await prefs.setString('capturedPokemonId_$capturedCount', pokemonId);
    capturedCount++;
    await prefs.setInt('capturedPokemonsCount', capturedCount);

    setState(() {
      _isPokemonCaptured = true;
    });
  }

  // Future<void> _clearCapturedPokemons() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('capturedPokemonsCount');

  //   final capturedCount = prefs.getInt('capturedPokemonsCount') ?? 0;
  //   for (int i = 0; i < capturedCount; i++) {
  //     await prefs.remove('capturedPokemonId_$i');
  //   }
  // }

  //Buscar pelo ID
  Future<PokeAPI?> _fetchPokemonById(String id) async {
    final provider = Provider.of<PokeApiProvider>(context, listen: false);
    final filteredPokemon = provider.pokemonList?.where((p) => p.id.toString() == id).toList();

    return filteredPokemon != null && filteredPokemon.isNotEmpty ? filteredPokemon.first : null;
  }

  double _calculatePercentage(int value, int max) {
    return value / max;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Capture Pokémon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: _randomPokemon != null
            ? Card(
                elevation: 4,
                margin: EdgeInsets.all(16.0),
                color: const Color.fromARGB(255, 180, 215, 227),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_randomPokemon!.id.toString().padLeft(3, '0')}.png',
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: 200,
                        height: 200,
                      ),
                      SizedBox(height: 20),
                      Text(
                        _randomPokemon!.name!.english!,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text('Dados do Pokémon:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('HP: ${_randomPokemon?.base?.hp ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                      Container(
                        height: 20,
                        child: LinearProgressIndicator(
                          value: _calculatePercentage(_randomPokemon?.base?.hp ?? 0, 255),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Ataque: ${_randomPokemon?.base?.attack ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                      Container(
                        height: 20,
                        child: LinearProgressIndicator(
                          value: _calculatePercentage(_randomPokemon?.base?.attack ?? 0, 190),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Defesa: ${_randomPokemon?.base?.defense ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                      Container(
                        height: 20,
                        child: LinearProgressIndicator(
                          value: _calculatePercentage(_randomPokemon?.base?.defense ?? 0, 230),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Velocidade: ${_randomPokemon?.base?.speed ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                      Container(
                        height: 20,
                        child: LinearProgressIndicator(
                          value: _calculatePercentage(_randomPokemon?.base?.speed ?? 0, 180),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isPokemonCaptured
                            ? null
                            : () async {
                                await _capturePokemon(_randomPokemon!.id!);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 87, 163),
                        ),
                        child: Text(
                          _isPokemonCaptured ? 'Pokémon Capturado' : 'Capturar Pokémon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     await _clearCapturedPokemons();
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text('Pokémons capturados foram limpos!')),
                      //     );
                      //   },
                      //   child: Text('Limpar Pokémon Capturados'),
                      // ),
                    ],
                  ),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
