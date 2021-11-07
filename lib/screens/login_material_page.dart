import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/screens/random_words.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/services/auth_repository.dart';



class LoginWidget extends StatelessWidget {
  LoginWidget({Key? key}) : super(key: key);
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
              Consumer<AuthRepository>(builder: (context, authRepositoryInst, _)
              => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: raisedButtonStyle,
                  child:
                  authRepositoryInst.status == Status.Authenticating
                      ? Text((() {
                    print(" loading");
                    return "Logging in ...";
                  })())
                      : Text((() {
                    _loading = false;
                    return "Log In";
                  })()),
                  onPressed: _loading? null : () async{
                    bool loggedIn = await authRepositoryInst.signIn(emailController.text,
                        passwordController.text);
                    buildLoading(context); //building CircularProgressIndicator
                    if(loggedIn == false) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar
                        (loginFailedSnackBar);
                    }else{
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RandomWords()));
                    }
                  },

              ),
                  )
                ),
            ]
        ),
      ),
    );
  }
  buildLoading(BuildContext context) {
    _loading = true;
    print("should wait UI");
    return showDialog(
        context: context,
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

