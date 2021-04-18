import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:regexed_validator/regexed_validator.dart';
import '../main.dart';
import 'CustomButton.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'LoginPage';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String error = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  Future<User> loginUser() async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User user = result.user;
      return user;
    } catch (e) {
      return null;
    }
  }

  void createUserDoc() {
    FirebaseFirestore.instance
        .collection("Profiles")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({
      "Name": FirebaseAuth.instance.currentUser.displayName,
      "Email": FirebaseAuth.instance.currentUser.email,
      "Profile Image": FirebaseAuth.instance.currentUser.photoURL,
    });
  }

  Future<User> googlesignin() async {
    try {
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gSA.accessToken,
        idToken: gSA.idToken,
      );
      User user = (await _auth.signInWithCredential(credential)).user;
      return user;
    } catch (e) {
      return null;
    }
  }

  String emailValidation(String str) {
    if (validator.email(str)) {
      return null;
    } else if (str.length == 0) {
      return 'Email required';
    } else {
      return 'Enter a valid email!';
    }
  }

  String passwordValidation(String str) {
    if (validator.password(str)) {
      return null;
    } else if (str.length == 0) {
      return 'Password required';
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator()
        : Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PoppinsRegular'),
                      ),
                      SizedBox(height: 35.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          'Welcome back,\nplease login\nto your account',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'PoppinsRegular',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 35.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'PoppinsRegular',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              validator: (val) => emailValidation(val),
                            ),
                            SizedBox(height: 15.0),
                            TextFormField(
                              controller: passwordController,
                              autocorrect: false,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'PoppinsRegular',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              validator: (val) => passwordValidation(val),
                            ),
                            SizedBox(height: 20.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: CustomButton(
                                    Height: 0.0,
                                    lol: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontFamily: 'PoppinsRegular',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    colour: Colors.blueAccent,
                                    callback: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() => loading = true);
                                        User user = await loginUser();
                                        if (user == null) {
                                          setState(() {
                                            loading = false;
                                            error =
                                                'Could not sign in with current credentials';
                                          });
                                        } else {
                                          setState(() {
                                            loading = false;
                                          });

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => QuizPage(),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0)),
                      Row(children: <Widget>[
                        Expanded(
                          child: new Container(
                              margin: const EdgeInsets.only(
                                  left: 50.0, right: 15.0),
                              child: Divider(
                                color: Colors.black,
                                height: 50,
                              )),
                        ),
                        Text(
                          "OR",
                          style: TextStyle(fontSize: 12),
                        ),
                        Expanded(
                          child: new Container(
                            margin:
                                const EdgeInsets.only(left: 15.0, right: 50.0),
                            child: Divider(
                              color: Colors.black,
                              height: 50,
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: CustomButton(
                              Height: 0.0,
                              lol: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/images/google.png",
                                    height: 25,
                                    width: 25,
                                  ),
                                  Opacity(
                                    opacity: 0.50,
                                    child: Text(
                                      'Log in with Google',
                                      style: TextStyle(
                                          fontFamily: 'PoppinsRegular',
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                              colour: Colors.white,
                              callback: () async {
                                setState(() => loading = true);
                                User user = await googlesignin();
                                if (user == null) {
                                  setState(() {
                                    loading = false;
                                    error =
                                        'Some error occured, please try again later';
                                  });
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  createUserDoc();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizPage(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'PoppinsRegular',
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegistrationPage(),
                                  ),
                                );
                              },
                              child: Text(
                                ' Sign Up',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'PoppinsRegular',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
