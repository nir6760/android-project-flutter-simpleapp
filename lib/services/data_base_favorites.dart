import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseServiceFavorites {
  final String uid;

  DatabaseServiceFavorites({required this.uid});

  // collection reference
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Set<WordPair> _favoriteSetFromDocumentSnapShot(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    var cluodFavoriteList = List.from(data['favorites']);
    var cluodFavoriteList_wordpair = cluodFavoriteList.map((s) => s as String);
    var regExp = RegExp(r"(?<=[a-z])(?=[A-Z])");
    Set<WordPair> ret = {};
    for (String w in cluodFavoriteList_wordpair) {
      var words = w.split(regExp);
      WordPair wp = WordPair(words[0].toLowerCase(), words[1].toLowerCase());
      ret.add(wp);
    }
    return ret;
  }

  // get user favorite stream
  Stream<Set<WordPair>> get favorites {
    return users.doc(uid).snapshots().map(_favoriteSetFromDocumentSnapShot);
  }

  Future<void> getUserEmail() async {
    DocumentSnapshot<Object?> snap = await users.doc(uid).get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    print("email: ${data['email']}");
  }

  Future<Set<WordPair>> getFavorites() async {
    DocumentSnapshot<Object?> snap = await users.doc(uid).get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    var cluodFavoriteList = List.from(data['favorites']);
    var cluodFavoriteList_wordpair = cluodFavoriteList.map((s) => s as String);
    var regExp = RegExp(r"(?<=[a-z])(?=[A-Z])");
    Set<WordPair> ret = {};
    for (String w in cluodFavoriteList_wordpair) {
      var words = w.split(regExp);
      WordPair wp = WordPair(words[0].toLowerCase(), words[1].toLowerCase());
      ret.add(wp);
    }
    return ret;
  }

  Future<void> updateFavorites(WordPair pair) async {
    var snap = users.doc(uid);
    var add_list = [pair.asPascalCase];
    await snap
        . // <-- Document ID
        update({'favorites': FieldValue.arrayUnion(add_list)}) // <-- Add data
        .then((_) => print('Added'))
        .catchError((error) => print('Add failed: $error'));
  }

  void updateFavoriteByList(Set<WordPair> lwp) {
    for (WordPair w in lwp) {
      updateFavorites(w);
    }
  }

  Future<void> deleteFavorites(WordPair pair) async {
    var snap = users.doc(uid);
    var del_list = [pair.asPascalCase];
    await snap
        . // <-- Document ID
        update({'favorites': FieldValue.arrayRemove(del_list)}) // <-- Add data
        .then((_) => print('Deleted'))
        .catchError((error) => print('Delete failed: $error'));
  }

  Future<void> addUserDoc(String email) async {
    users
        .doc(uid)
        .set({"email": email, "avatar_url": "no_avatar", "favorites": []}).then(
            (value) {
      print("User Added");
    }).catchError((error) => print("Failed to add user: $error"));
  }

  //*********************************************************
  //Avatar functions
  Future<String> uploadFile(String _avatarPath) async {
    try {
      File _avatarFile = File(_avatarPath);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('avatars').child(uid);
      try {
        await storageReference.putFile(_avatarFile);
        print('File Uploaded');
      } on FirebaseException catch (e) {
        print("Error is " + e.toString());
        // e.g, e.code == 'canceled'
      }
      String fileUrl = await storageReference.getDownloadURL();
      return fileUrl;
    } catch (e) {
      print(e);
      return "no_avatar";
      // e.g, e.code == 'canceled'
    }
  }

  Future<String> getUserAvatarUrl() async {
    DocumentSnapshot<Object?> snap = await users.doc(uid).get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    if (!data.containsKey('avatar_url')) return "no_avatar";
    return data['avatar_url'];
  }

  Future<void> updateAvatarUrl(String newUrl) async {
    var snap = users.doc(uid);
    await snap
        . // <-- Document ID
        update({'avatar_url': newUrl}) // <-- Add data
        .then((_) => print('avatar updated'))
        .catchError((error) => print('avatar updated failed: $error'));
  }
}
