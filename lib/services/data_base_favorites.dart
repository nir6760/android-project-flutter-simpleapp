import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';

class DatabaseServiceFavorites {

  final String uid;
  DatabaseServiceFavorites({ required this.uid });

  // collection reference
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Set<WordPair> _favoriteSetFromDocumentSnapShot(DocumentSnapshot snap){
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    var cluodFavoriteList = List.from(data['favorites']);
    var cluodFavoriteList_wordpair = cluodFavoriteList.map((s) => s as String);
    var regExp = RegExp(r"(?<=[a-z])(?=[A-Z])");
    Set<WordPair> ret = {};
    for(String w in cluodFavoriteList_wordpair){
      var words = w.split(regExp);
      WordPair wp = WordPair(words[0].toLowerCase(), words[1].toLowerCase());
      ret.add(wp);
    }
    return ret;
  }

  // get user favorite stream
  Stream<Set<WordPair>> get favorites{
    return users.doc(uid).snapshots().map(_favoriteSetFromDocumentSnapShot);
  }


  Future<void> getUserEmail() async {
    DocumentSnapshot<Object?> snap =  await users.doc(uid).get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    print("email: ${data['email']}");
  }

  Future<Set<WordPair>> getFavorites() async {
    DocumentSnapshot<Object?> snap =  await users.doc(uid).get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    var cluodFavoriteList = List.from(data['favorites']);
    var cluodFavoriteList_wordpair = cluodFavoriteList.map((s) => s as String);
    var regExp = RegExp(r"(?<=[a-z])(?=[A-Z])");
    Set<WordPair> ret = {};
    for(String w in cluodFavoriteList_wordpair){
      var words = w.split(regExp);
      WordPair wp = WordPair(words[0].toLowerCase(), words[1].toLowerCase());
      ret.add(wp);
    }
    return ret;
  }

  Future<void> updateFavorites(WordPair pair) async {
    var snap =  users.doc(uid);
    var add_list = [pair.asPascalCase];
    await snap. // <-- Document ID
        update({'favorites': FieldValue.arrayUnion(add_list)}) // <-- Add data
        .then((_) => print('Added'))
        .catchError((error) => print('Add failed: $error'));

  }
  void updateFavoriteByList(Set<WordPair> lwp){
    for(WordPair w in lwp){
      updateFavorites(w);
    }
  }
  Future<void> deleteFavorites(WordPair pair) async {
    var snap =  users.doc(uid);
    var del_list = [pair.asPascalCase];
    await snap. // <-- Document ID
    update({'favorites': FieldValue.arrayRemove(del_list)}) // <-- Add data
        .then((_) => print('Deleted'))
        .catchError((error) => print('Delete failed: $error'));

  }

}