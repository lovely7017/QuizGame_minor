import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';
import 'CustomButton.dart';
import 'LoginPage.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'RegistrationPage';
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  String error = '';

  Future<User> registerUser() async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User user = result.user;
      return user;
    } catch (e) {
      print(e);
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

  String emailValidation(String str) {
    if (validator.email(str)) {
      return null;
    } else {
      return 'Enter a valid email!';
    }
  }

  String passwordValidation(String str) {
    if (validator.password(str)) {
      return null;
    } else if (str.length == 0) {
      return 'Password required';
    } else {
      return 'Too weak';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    bool loading = false;
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
                        'Register',
                        style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PoppinsRegular'),
                      ),
                      SizedBox(height: 35.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          'Let\'s get\nyou on board',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'PoppinsRegular',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'Full Name',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'PoppinsRegular',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              validator: (val) {
                                if (val.length < 1)
                                  return 'Name Required';
                                else
                                  return null;
                              },
                            ),
                            SizedBox(height: 15.0),
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
                            SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width - 40,
                              child: Text(
                                "Password must contain:\n    *At least 1 lower case character[a-z]\n    *At least 1 Higher case character[A-Z]\n    *At least 1 Special case character[@,_,),etc.]\n    *At least 1 Numerical character[0-9]",
                                style: TextStyle(
                                    fontFamily: 'PoppinsRegular',
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0),
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: CustomButton(
                                      Height: 0.0,
                                      lol: Text(
                                        'Register',
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
                                          User user = await registerUser();
                                          if (user == null) {
                                            setState(() {
                                              loading = false;
                                              error =
                                                  'Could not sign up with current credentials';
                                            });
                                          } else {
                                            await user.updateProfile(
                                                displayName: nameController.text
                                                    .split(" ")
                                                    .map((str) =>
                                                        str.replaceFirst(
                                                            str[0],
                                                            str[0]
                                                                .toUpperCase()))
                                                    .join(" "));
                                            await user.reload();
                                            createUserDoc();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    QuizPage(),
                                              ),
                                            );
                                          }
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(error,
                          style: TextStyle(color: Colors.red, fontSize: 12.0)),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Already have an account? ',
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
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                ' Sign in',
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
