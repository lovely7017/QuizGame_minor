import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'authentication/LoginPage.dart';
import 'quiz_brain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Quizzler());
}

class Quizzler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: FirebaseAuth.instance.currentUser == null
                ? LoginPage()
                : QuizPage(),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int scoreKeeper = 0;
  int score = 0;
  bool start = false;
  QuizBrain quizBrain = QuizBrain();

  void checkAnswer(bool userPickedAnswer) {
    bool correctAnswer = quizBrain.getCorrectAnswer();

    setState(() {
      if (quizBrain.isFinished() == true) {
        Alert(
          context: context,
          title: 'Finished!',
          desc: 'You\'ve reached the end of the quiz.\nYour score is ${score}.',
        ).show();
        quizBrain.reset();
        scoreKeeper = 0;
        score = 0;
      } else {
        if (userPickedAnswer == correctAnswer) {
          score += 1;
        }
        scoreKeeper += 1;
        quizBrain.nextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: start
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Opacity(
                          opacity: 0.7,
                          child: Text(
                            "${score}/${scoreKeeper}",
                            style: TextStyle(color: Colors.black),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        quizBrain.getQuestionText(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    margin: EdgeInsets.all(15.0),
                    child: TextButton(
                      child: Text(
                        'True',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      onPressed: () {
                        //The user picked true.
                        checkAnswer(true);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.red,
                    margin: EdgeInsets.all(15.0),
                    child: TextButton(
                      child: Text(
                        'False',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      onPressed: () {
                        //The user picked true.
                        checkAnswer(false);
                      },
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                child: TextButton(
                  child: Text(
                    'Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      start = true;
                      score = 0;
                    });
                  },
                ),
              ),
            ),
    );
  }
}
