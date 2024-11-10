import 'package:flutter/material.dart';
import 'package:pokedex_app/pages/home_page/widgets/capture_pokemon_page.dart';
import 'package:pokedex_app/pages/home_page/widgets/my_pokemons_page.dart';
import 'package:pokedex_app/pages/home_page/widgets/pokedex_page.dart';
import 'package:pokedex_app/providers/pokeapi_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); //Gerencia a exibição dos dados
}

//Carrega os dados e constrói a interface
class _HomePageState extends State<HomePage> {
  @override
  void initState() { //Chamado quando HomePage é criado a primeira vez
    super.initState(); //Garante que seja antes 
    // _loadPokemons();
  }

//Carrega a lista
  Future<void> _loadPokemons() async {
    final provider = Provider.of<PokeApiProvider>(context, listen: false); //Mostrar o provider
    await provider.fetchPokemonList(); //Carrega a lista dos pokemons
    await provider.loadCapturedPokemons(); //Carrega a lista de pokemons capturados (salvos localmente)
  }

//Construir interface
  @override
  Widget build(BuildContext context) {
    return Scaffold( //Cria estrutura básica
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/RMK12626RL_1800x1800.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Bem-vindo ao Pokedex!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                _buildButton(
                  context,
                  'Pokedex',
                  PokedexPage(),
                ),
                SizedBox(height: 20),
                _buildButton(
                  context,
                  'Encontro Diário',
                  CapturePokemonPage(),
                ),
                SizedBox(height: 20),
                _buildButton(
                  context,
                  'Meus Pokemons',
                  MeusPokemonsPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//Definições dos botões
  Widget _buildButton(BuildContext context, String text, Widget page) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Color.fromARGB(255, 180, 215, 227),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
