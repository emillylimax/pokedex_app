import 'package:flutter/material.dart';
import 'package:pokedex_app/pages/home_page/widgets/my_pokemons_details_page.dart';
import 'package:pokedex_app/providers/pokeapi_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex_app/models/pokeapi.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MeusPokemonsPage extends StatefulWidget {
  @override
  _MeusPokemonsPageState createState() => _MeusPokemonsPageState();
}


//Estado da Classe
class _MeusPokemonsPageState extends State<MeusPokemonsPage> {
  List<PokeAPI> _capturedPokemons = []; //Armazena lista dos pokemons capturados
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCapturedPokemons();
  }

  //Carrega pokemons capturados
  Future<void> _loadCapturedPokemons() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final capturedPokemonsCount = prefs.getInt('capturedPokemonsCount') ?? 0; //Recupera total de pokemons capturados

    _capturedPokemons.clear(); //Limpa a lista pra não ter duplicidades

  //Percorre e vai adicionando
    for (int i = 0; i < capturedPokemonsCount; i++) {
      final pokemonId = prefs.getString('capturedPokemonId_$i');
      if (pokemonId != null) {
        final pokemon = await _fetchPokemonById(pokemonId);
        if (pokemon != null) {
          _capturedPokemons.add(pokemon);
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

//Método pra buscar Pokemon pelo ID
  Future<PokeAPI?> _fetchPokemonById(String id) async {
    final provider = Provider.of<PokeApiProvider>(context, listen: false);
    try {
      return provider.pokemonList?.firstWhere(
        (p) => p.id.toString() == id,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meus Pokémons',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _capturedPokemons.isEmpty
              ? Center(child: Text('Você não capturou nenhum Pokémon ainda.'))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _capturedPokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = _capturedPokemons[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyPokemonDetailsPage(pokemon: pokemon),
                          ),
                        );

                        if (result == 'released') {
                          await _loadCapturedPokemons();
                        }
                      },
                      child: Card(
                        elevation: 4.0,
                        color: const Color.fromARGB(255, 180, 215, 227),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png',
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              width: 150,
                              height: 150,
                            ),
                            SizedBox(height: 8),
                            Text(pokemon.name?.english ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}