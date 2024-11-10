import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_app/models/pokeapi.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MyPokemonDetailsPage extends StatelessWidget {
  final PokeAPI pokemon;

  const MyPokemonDetailsPage({Key? key, required this.pokemon}) : super(key: key);

  //Liberar o Pokemon
  //Recupera o número de capturados, percorre todos capturados e remove o ID do pokemon liberado e atualiza total.
  Future<void> _releasePokemon(BuildContext context, String pokemonId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> capturedPokemonIds = [];
    
    int capturedCount = prefs.getInt('capturedPokemonsCount') ?? 0;
    for (int i = 0; i < capturedCount; i++) {
      String? id = prefs.getString('capturedPokemonId_$i');
      if (id != null && id != pokemonId) {
        capturedPokemonIds.add(id);
      }
    }
    
    // Atualiza a contagem de Pokémons capturados
    prefs.setInt('capturedPokemonsCount', capturedPokemonIds.length);
    for (int i = 0; i < capturedPokemonIds.length; i++) {
      prefs.setString('capturedPokemonId_$i', capturedPokemonIds[i]);
    }

    Navigator.pop(context, 'released');
  }

  //Tela de confirmação
  void _showReleaseConfirmationDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Confirmar Ação',
      desc: 'Tem certeza de que deseja soltar este Pokémon?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _releasePokemon(context, pokemon.id.toString());
      },
    ).show();
  }

  double _calculatePercentage(int value, int max) {
    return max > 0 ? value / max : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes do Pokémon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Card(
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
                  imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png',
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                Text(
                  pokemon.name?.english ?? 'Desconhecido',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Dados do Pokémon:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),

                Text('HP: ${pokemon.base?.hp ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                Container(
                  height: 20,
                  child: LinearProgressIndicator(
                    value: _calculatePercentage(pokemon.base?.hp ?? 0, 255),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                  ),
                ),
                SizedBox(height: 8),

                Text('Ataque: ${pokemon.base?.attack ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                Container(
                  height: 20,
                  child: LinearProgressIndicator(
                    value: _calculatePercentage(pokemon.base?.attack ?? 0, 190),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                  ),
                ),
                SizedBox(height: 8),

                Text('Defesa: ${pokemon.base?.defense ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                Container(
                  height: 20, 
                  child: LinearProgressIndicator(
                    value: _calculatePercentage(pokemon.base?.defense ?? 0, 230),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                  ),
                ),
                SizedBox(height: 8),

                Text('Velocidade: ${pokemon.base?.speed ?? 'Desconhecido'}', style: TextStyle(fontSize: 16)),
                Container(
                  height: 20, 
                  child: LinearProgressIndicator(
                    value: _calculatePercentage(pokemon.base?.speed ?? 0, 180),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 98, 147)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showReleaseConfirmationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 87, 163),
                  ),
                  child: Text(
                    'Soltar Pokémon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}