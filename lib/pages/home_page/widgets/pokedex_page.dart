import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokedex_app/providers/pokeapi_provider.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_app/models/pokeapi.dart';
import 'package:pokedex_app/pages/home_page/widgets/poke_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokedexPage extends StatefulWidget {
  @override
  _PokedexPageState createState() => _PokedexPageState();
}

//Define a quantidade de itens carregados por vez
class _PokedexPageState extends State<PokedexPage> {
  static const _pageSize = 20;
  final PagingController<int, PokeAPI> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) { //Chamada sempre que uma página nova precisa ser carregada
      _fetchPage(pageKey);
    });
    _fetchPage(0); //Carrega a primeira página
  }

  //Carrega os pokemons da página específica
  Future<void> _fetchPage(int pageKey) async {
    try {
      final pokeApiProvider = Provider.of<PokeApiProvider>(context, listen: false);
      List<PokeAPI> newItems = [];

      // Carrega um lote de pokémons individualmente, 20 por vez
      for (int i = pageKey + 1; i <= pageKey + _pageSize; i++) {
        final pokemon = await pokeApiProvider.fetchPokemonById(i.toString());
        if (pokemon != null) {
          newItems.add(pokemon); //Adiciona pokemon a lista de novos itens
        }
      }

      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems); //Se for a última, chama append pra indicar que acabou
      } else { //Se não, continua carregando
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokedex',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PagedListView<int, PokeAPI>.separated( //Lista com paginação infinita
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<PokeAPI>(
          itemBuilder: (context, item, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PokeDetailsPage(pokemon: item)),
                );
              },
              child: Card(
                color: Color.fromARGB(255, 201, 235, 247),
                child: ListTile(
                  title: Text(
                    item.name?.english ?? 'Nome desconhecido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: CachedNetworkImage( //Usa o cache
                    imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${item.id.toString().padLeft(3, '0')}.png',
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            );
          },
        ),
        separatorBuilder: (context, index) => Divider(
          color: Colors.white, 
          height: 2,            
        ),
      ),
    );
  }

  //Controlador de paginação é descartado
  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
