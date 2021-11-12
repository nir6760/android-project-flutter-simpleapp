import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/screens/random_words.dart';
import 'package:hello_me/services/data_base_favorites.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/services/auth_repository.dart';




class LoginWidget extends StatefulWidget {
  Set<WordPair> _saved;
  LoginWidget(this._saved , {Key? key}) : super(key: key);
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}
class _LoginWidgetState extends State<LoginWidget> {
  bool _loading = false;
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

    const loginFailedSnackBar =
    SnackBar(content: Text("There was an error logging into the app"));
    var authRepositoryInst = Provider.of<AuthRepository>(context, listen: false);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body:Center(
        child: ListView(
            children: <Widget>[
              SizedBox(height: 48.0),
              welcomTxt,
              SizedBox(height: 48.0),
              email,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child:
                !_loading?
                  ElevatedButton(
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
                        loggedIn =
                        await authRepositoryInst.signIn(emailController.text,
                            passwordController.text);
                      }
                      setState(() {
                        _loading = false;
                      });

                      if (loggedIn == false) {
                        //Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar
                        (loginFailedSnackBar);

                      } else {
                        //Navigator.of(context).pop();
                        // Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //         builder: (context) => const RandomWords()));
                        DatabaseServiceFavorites? favoritesDb;
                        favoritesDb =
                            DatabaseServiceFavorites(uid: authRepositoryInst.user!.uid);
                        //upload all to cloud
                        favoritesDb.updateFavoriteByList(widget._saved);
                        //remove locally
                        widget._saved= <WordPair>{};
                        Navigator.pop(context);
                      }
                    }
              )
              :
                Center(child:CircularProgressIndicator())
              )

            ]
        ),
      ),
    );
  }
  buildLoading(BuildContext context) {

    print("should wait UI");
    return showDialog(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        });
  }
}

