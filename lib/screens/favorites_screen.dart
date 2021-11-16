import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/services/data_base_favorites.dart';
import 'package:hello_me/snappingSheet/propile_snapping.dart';

MaterialPageRoute<void> materialPageRouteFavorites(BuildContext context,
    Set<WordPair> _saved, DatabaseServiceFavorites? favoritesDb) {
  return MaterialPageRoute<void>(builder: (context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        showAlertDialog(WordPair wordpair) {
          // set up the button
          Widget yesButton = ElevatedButton(
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (favoritesDb != null) {
                favoritesDb.deleteFavorites(wordpair);
              }
              setState(() {
                _saved.remove(wordpair);
              });
              Navigator.pop(context, 'Yes');
            },
          );
          Widget noButton = ElevatedButton(
            child: Text(
              "No",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context, 'No');
            },
          );

          // set up the AlertDialog
          AlertDialog alert = AlertDialog(
            title: const Text("Delete Suggestion"),
            content: Text("Are you sure you want to delete " +
                wordpair.asPascalCase.toString() +
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
          ).then((val) => val);
        }

        const deleteSuggestionSnackBar =
            SnackBar(content: Text('Deletion is not implemented yet'));
        final tiles = _saved.map(
          (pair) {
            return Dismissible(
                key: ValueKey<WordPair>(pair),
                child: ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                background: Container(
                  color: Colors.deepPurple,
                  alignment: Alignment.centerLeft,
                  child: Row(children: const <Widget>[
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Text("Delete Suggestion",
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                  ]),
                ),
                confirmDismiss: (DismissDirection direction) async {
                  showAlertDialog(pair);

                  //ScaffoldMessenger.of(context).showSnackBar(deleteSuggestionSnackBar);
                  return false;
                },
                onDismissed: (DismissDirection direction) {});
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => RandomWords()),
              // );
            ),
            title: const Text('Saved Suggestions'),
          ),
          body: (favoritesDb != null)
              ? ProfileSnapping(listView(divided))
              : listView(divided),
        );
      },
    );
  });
}

ListView listView(List<Widget> divided) => ListView(children: divided);
