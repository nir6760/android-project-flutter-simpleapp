import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/screens/login_material_page.dart';
import 'package:provider/provider.dart';

import '../services/auth_repository.dart';

class RandomWords extends StatefulWidget {
  static String tag = 'RandomWords-page';
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  //final _suggestions = generateWordPairs().take(10).toList();
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool _loggedIn = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(builder: (context, authRepositoryInst, _)
    =>
      Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator', overflow: TextOverflow.ellipsis,),
          actions: [
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: _pushLogin,
              tooltip: 'login',
            ),
            if(authRepositoryInst.isAuthenticated)
              IconButton(
              icon: const Icon(Icons.logout),
              onPressed:() async{
                 await authRepositoryInst.signOut();
              },
              tooltip: 'exit_to_app',
            ),
          ],
        ),
        body: _buildSuggestions(),
      )
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginWidget()),
    );
  }


  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          const deleteSuggestionSnackBar =
          SnackBar(content: Text('Deletion is not implemented yet'));
          final tiles = _saved.map(
                (pair) {
              return Dismissible(key: ValueKey<WordPair>(pair),
                  child: ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                  ),
                background: Container(
                  color: Colors.deepPurple,
                  alignment: Alignment.centerLeft,
                  child:  Row(
                      children: const <Widget>[
                        Icon(Icons.delete, color: Colors.white,),
                        Text("Delete Suggestion",
                          style: TextStyle(color: Colors.white, fontSize: 17)),
                      ]
                  ),
                ),
                  confirmDismiss:
                      (DismissDirection direction) async {
                        showAlertDialog(context, pair.asPascalCase.toString());
                    //ScaffoldMessenger.of(context).showSnackBar(deleteSuggestionSnackBar);
                    return false;
                  },
                onDismissed: (DismissDirection direction) {


                  }
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        // The itemBuilder callback is called once per suggested
        // word pairing, and places each suggestion into a ListTile
        // row. For even rows, the function adds a ListTile row for
        // the word pairing. For odd rows, the function adds a
        // Divider widget to visually separate the entries. Note that
        // the divider may be difficult to see on smaller devices.
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return Divider();
          }

          // The syntax "i ~/ 2" divides i by 2 and returns an
          // integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings
          // in the ListView,minus the divider widgets.
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          if (index >= _suggestions.length) {
            // ...then generate 10 more and add them to the
            // suggestions list.
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Colors.deepPurple : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }
}

showAlertDialog(BuildContext context, String wordpair) {

  // set up the button
  Widget yesButton = ElevatedButton(
    child: Text("Yes", style: TextStyle(color: Colors.white)),
    onPressed: () { },
  );
  Widget noButton = ElevatedButton(
    child: Text("No", style: TextStyle(color: Colors.white),),
    onPressed: () { },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Delete Suggestion"),
    content: Text("Are you sure you want to delete " + wordpair +
        " from your saved suggestions?"),
    actions: [
      yesButton,
      noButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}