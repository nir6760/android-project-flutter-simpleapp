import 'package:flutter/material.dart';
import 'random_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    RandomWords.tag: (context) => RandomWords(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(

        ),
      ),
      home: RandomWords(),
      routes: routes,
    );
  }
}






