import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/services/auth_repository.dart';
import 'package:hello_me/services/data_base_favorites.dart';
import 'package:provider/provider.dart';

class LoginWidget extends StatefulWidget {
  Set<WordPair> _saved;

  LoginWidget(this._saved, {Key? key}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool _loading = false;
  bool _loading_confirmation = false;
  static const loginFailedSnackBar =
      SnackBar(content: Text("There was an error logging into the app"));
  static const signinFailedSnackBar =
      SnackBar(content: Text("There was an error sign into the app"));
  static const confirmFailedSnackBar =
      SnackBar(content: Text("Confirmation failed"));

  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    );

    const welcomTxt = Text(
      'Welcome to Startup Name Generator. please log in below',
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    );
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      initialValue: null,
      controller: emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
    final password = TextFormField(
      autofocus: false,
      initialValue: null,
      obscureText: true,
      controller: passwordController,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );

    var authRepositoryInst =
        Provider.of<AuthRepository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ListView(children: <Widget>[
          const SizedBox(height: 48.0),
          welcomTxt,
          const SizedBox(height: 48.0),
          email,
          const SizedBox(height: 8.0),
          password,
          const SizedBox(height: 24.0),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 2),
              child: !_loading
                  ? ElevatedButton(
                      style: raisedButtonStyle,
                      child: Text((() {
                        return "Log In";
                      })()),
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        bool loggedIn = false;
                        if (emailController.text.isNotEmpty &&
                            emailController.text.isNotEmpty) {
                          loggedIn = await authRepositoryInst.signIn(
                              emailController.text, passwordController.text);
                        }
                        setState(() {
                          _loading = false;
                        });

                        if (loggedIn == false) {
                          //Navigator.of(context).pop();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(loginFailedSnackBar);
                        } else {
                          //Navigator.of(context).pop();
                          // Navigator.of(context).push(
                          //     MaterialPageRoute(
                          //         builder: (context) => const RandomWords()));
                          DatabaseServiceFavorites? favoritesDb;
                          favoritesDb = DatabaseServiceFavorites(
                              uid: authRepositoryInst.user!.uid);
                          //upload all to cloud
                          favoritesDb.updateFavoriteByList(widget._saved);
                          //remove locally
                          widget._saved = <WordPair>{};
                          Navigator.pop(context);
                        }
                      })
                  : Center(child: CircularProgressIndicator())),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 1, 10, 2),
              child: !_loading_confirmation
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: const EdgeInsets.all(12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                      ),
                      child: Text((() {
                        return "New user? Click to sign up";
                      })()),
                      onPressed: () {
                        if (emailController.text.isNotEmpty &&
                            emailController.text.isNotEmpty) {
                          _addProcedureBottomSheet(context, authRepositoryInst,
                              emailController.text, passwordController.text);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(signinFailedSnackBar);
                          return;
                        }
                      })
                  : const Center(child: CircularProgressIndicator()))
        ]),
      ),
    );
  }

  void _addProcedureBottomSheet(BuildContext context,
      AuthRepository authRepositoryInst, String newEmail, String newPassword) {
    TextEditingController passwordConfirmController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: 10,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      'Please confirm your password below:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      validator: (text) {
                        if (text != newPassword) {
                          return "Passwords must match";
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  Center(
                      child: TextButton(
                    child: const Text(
                      '   Confirm   ',
                      style:
                          TextStyle(fontStyle: FontStyle.normal, fontSize: 18),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.lightBlue,
                      onSurface: Colors.grey,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading_confirmation = true;
                        });
                        bool loggedIn = false;
                        UserCredential? newUser;
                        newUser = await authRepositoryInst.signUp(
                            newEmail, newPassword);
                        if (newUser == null) {
                          loggedIn == false;
                          print('no new user');
                          //Navigator.of(context).pop();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(signinFailedSnackBar);
                        } else {
                          print('new user created');
                          DatabaseServiceFavorites? favoritesDb;
                          favoritesDb = DatabaseServiceFavorites(
                              uid: authRepositoryInst.user!.uid);
                          await favoritesDb.addUserDoc(newEmail);
                          //upload all to cloud
                          favoritesDb.updateFavoriteByList(widget._saved);
                          //remove locally
                          widget._saved = <WordPair>{};

                          Navigator.pop(context); // from modal to log in
                          Navigator.pop(context); //from log in to random_words
                        }
                        setState(() {
                          _loading_confirmation = false;
                        });
                      }
                    },
                  )),
                ],
              ),
            ),
          ));
        });
  }
}

String? validatePassword(String newPassword, String value) {
  if (value != newPassword) {
    return "Passwords must match";
  }
  return null;
}
