import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/screens/login_material_page.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/services/auth_repository.dart';
import 'package:hello_me/screens/favorites_screen.dart';
import 'package:hello_me/services/data_base_favorites.dart';

class RandomWords extends StatefulWidget {
  static String tag = 'RandomWords-page';
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  bool loggedIn = false;
  final _suggestions = <WordPair>[];
  //final _suggestions = generateWordPairs().take(10).toList();
  late var _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);
  DatabaseServiceFavorites? favoritesDb;

  @override
  void initState() {
    super.initState();
  }
  // merge local saved set with cloud
  void mergeSaved() async{
    var l = await  favoritesDb!.getFavorites();
    _saved.addAll(l);
  }
  @override
  Widget build(BuildContext context) {
    print('building');
    return Consumer<AuthRepository>(builder: (context, authRepositoryInst, _){

      if(loggedIn==false && authRepositoryInst.isAuthenticated){
        favoritesDb =
            DatabaseServiceFavorites(uid: authRepositoryInst.user!.uid);
        favoritesDb!.updateFavoriteByList(_saved); //upload all to cloud
        var l =  favoritesDb!.getFavorites();
        // merge with cloud before display
        mergeSaved();
        loggedIn=true;
      }


      return
      Scaffold(
        appBar: AppBar(
          title: Center(
            child: RichText(text: const TextSpan(text: 'Startup Name Generator',
                style: TextStyle(fontSize: 20)),
            ),
          ),
          actions: [

            IconButton(
              icon: const Icon(Icons.star),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            if(authRepositoryInst.isAuthenticated)
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authRepositoryInst.signOut();
                  favoritesDb = null;
                  loggedIn = false;
                },
                tooltip: 'exit_to_app',
              )
            else
              IconButton(
                icon: const Icon(Icons.login),
                onPressed: _pushLogin,
                tooltip: 'login',
              ),
          ],
        ),
        body: FutureBuilder(
          future: loggedIn? favoritesDb!.getFavorites():null,
            builder: (BuildContext context, AsyncSnapshot<Set<WordPair>> _saved){
            if(_saved.connectionState == ConnectionState.done){
              if(_saved.hasError){
                return const Text("Sorry, an error occurred");
              }
              return _buildSuggestions(authRepositoryInst);
            }else{
              return listView();
            }

            },
        ),
      );
    }
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginWidget(_saved)),
    );
  }


  void _pushSaved() async{

    Navigator.of(context).push(
      materialPageRouteFavorites(context, _saved, favoritesDb),
    ).then((_) => setState(() {}));
  }



  Widget _buildSuggestions(AuthRepository authRepositoryInst) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
        //listening to users stream
      builder: (context, snapshot) {
        return listView();
      }
    );
  }

  ListView listView() {
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
            return _buildRow(_suggestions[index], favoritesDb);

          }
      );
  }

  Widget _buildRow(WordPair pair, DatabaseServiceFavorites? favoritesDb) {

    final alreadySaved = _saved.contains(pair);
    var authRepositoryInst = Provider.of<AuthRepository>(context, listen: false);

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
            if(authRepositoryInst.isAuthenticated){
              favoritesDb!.deleteFavorites(pair);
            }
          } else {
            print(pair);
            _saved.add(pair);
            if(authRepositoryInst.isAuthenticated){
              favoritesDb!.updateFavorites(pair);
            }
          }
        });
      },
    );
  }


}

