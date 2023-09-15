import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum GameStatus {
  unfinished,
  success,
  failure,
}

enum LetterStatus {
  invalid,
  correct,
  wrongLocation,
  unset,
}

extension LetterStatusExtension on LetterStatus {
  String get name => describeEnum(this);

  Color get squareColor {
    switch (this) {
      case LetterStatus.invalid:
        return Colors.grey;
      case LetterStatus.unset:
        return Colors.black;
      case LetterStatus.wrongLocation:
        return Colors.yellow;
      case LetterStatus.correct:
        return Colors.green;
    }
  }
}

class Guess {
  List<String> guessWord;
  List<LetterStatus> letterMatch;

  Guess({required this.guessWord, required this.letterMatch});

  factory Guess.empty() => Guess(
        guessWord: [],
        letterMatch: [
          LetterStatus.unset,
          LetterStatus.unset,
          LetterStatus.unset,
          LetterStatus.unset,
          LetterStatus.unset,
        ],
      );

  printGuess() {
    debugPrint(guessWord.toString());
  }
}

@freezed
class Game {
  List<String> gameWord;
  List<Guess> guesses;
  int guessCount;
  GameStatus gameStatus;
  int activeRow;
  int activeCol;
  int animateRow;
  bool submitAvailable;

  Game({
    required this.gameWord,
    required this.guesses,
    required this.guessCount,
    required this.gameStatus,
    required this.activeRow,
    required this.activeCol,
    required this.animateRow,
    required this.submitAvailable,
  });
}
