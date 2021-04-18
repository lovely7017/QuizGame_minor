import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'question.dart';

class QuizBrain {
  int _questionNumber = 0;
  List<Question> questionBank = [];
  QuizBrain() {
    FirebaseFirestore.instance.collection("Questions").get().then((value) {
      value.docs.forEach((element) {
        questionBank.add(
            Question(element.data()['Question'], element.data()["Solution"]));
      });
    });
    questionBank.shuffle();
  }

  void nextQuestion() {
    if (_questionNumber < questionBank.length - 1) {
      _questionNumber++;
    }
  }

  String getQuestionText() {
    return questionBank[_questionNumber].questionText;
  }

  bool getCorrectAnswer() {
    return questionBank[_questionNumber].questionAnswer;
  }

  //TODO: Step 3 Part A - Create a method called isFinished() here that checks to see if we have reached the last question. It should return (have an output) true if we've reached the last question and it should return false if we're not there yet.

  bool isFinished() {
    if (_questionNumber >= 10) {
      //TODO: Step 3 Part B - Use a print statement to check that isFinished is returning true when you are indeed at the end of the quiz and when a restart should happen.

      print('Now returning true');
      return true;
    } else {
      return false;
    }
  }

  //TODO: Step 4 part B - Create a reset() method here that sets the questionNumber back to 0.
  void reset() {
    _questionNumber = 0;
  }
}
