import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_app/providers/pokeapi_provider.dart';
import 'package:pokedex_app/pages/home_page/widgets/home_page.dart';

//Configura o ambiente inicial e inicia o aplicativo
void main() {
  runApp( //Widget raiz
    ChangeNotifierProvider(
      create: (context) => PokeApiProvider(), //Inicializa a instância
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}