import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wordle2/game_square.dart';
import 'package:wordle2/game_square_focus.dart';
import 'package:wordle2/models/game_model.dart';
import 'package:flutter/material.dart';

final gameController = StateNotifierProvider<GameController, Game>(
  (ref) {
    return GameController(ref);
  },
);

class GameController extends StateNotifier<Game> {
  final Ref ref;

  GameController(this.ref)
      : super(Game(
          gameWord: [],
          guesses: [],
          guessCount: 0,
          gameStatus: GameStatus.unfinished,
          activeRow: 0,
          activeCol: 0,
          animateRow: -1,
        ));

  void initializeGame({required String newGameWord}) {
    if (newGameWord.length == 5) {
      List<String> gameWord = newGameWord.split('');
      List<Guess> guesses = [];

      //TODO delete this
      guesses.add(Guess(guessWord: [
        'r',
        'o',
        'u',
        't',
        'e'
      ], letterMatch: [
        LetterStatus.unset,
        LetterStatus.unset,
        LetterStatus.unset,
        LetterStatus.unset,
        LetterStatus.unset,
      ]));

      guesses.add(Guess.empty());

      Game newGame = Game(
        gameWord: gameWord,
        guesses: guesses,
        guessCount: 1,
        gameStatus: GameStatus.unfinished,
        activeRow: 1,
        activeCol: 0,
        animateRow: -1,
      );

      if (mounted) {
        state = newGame;
      }
    }
  }

  bool saveGuess() {
    Game game = state;
    Guess currentGuess = game.guesses[game.activeRow];
    final List<String> gameWord = game.gameWord.toList();
    int guessCount = game.guessCount;
    List<LetterStatus> letterMatch = [
      LetterStatus.unset,
      LetterStatus.unset,
      LetterStatus.unset,
      LetterStatus.unset,
      LetterStatus.unset,
    ];

    for (Guess guess in game.guesses) {
      //If a repeat guess then invalid and have the user guess again.
      if (guess.guessWord == currentGuess.guessWord) {
        return false;
      }
    }
    //Mark all correct answers
    for (int i = 0; i < 5; i++) {
      if (currentGuess.guessWord[i] == gameWord[i]) {
        letterMatch[i] = LetterStatus.correct;
        //Make sure this letter can not be matched again.
        gameWord[i] = '_';
      }
    }
    //Mark all answers that are in the game but in a different location or as an invalid letter
    for (int i = 0; i < 5; i++) {
      if (letterMatch[i] == LetterStatus.unset) {
        int indexOfLetter = gameWord.indexOf(currentGuess.guessWord[i]);
        letterMatch[i] = LetterStatus.invalid;

        //If the letter is found in the game word but not an exact match
        if (indexOfLetter > -1) {
          letterMatch[i] = LetterStatus.wrongLocation;
          gameWord[i] = '_';
        }
      }
    }

    //TODO

    List<Guess> guesses = game.guesses.toList();
    Guess newGuess = Guess(guessWord: currentGuess.guessWord, letterMatch: letterMatch);
    guesses.removeLast();
    guesses.add(newGuess);

    if (mounted) {
      state = Game(
        gameWord: gameWord,
        guesses: guesses,
        guessCount: guessCount + 1,
        gameStatus: game.gameStatus,
        activeRow: game.activeRow + 1,
        activeCol: 0,
        animateRow: game.activeRow,
      );
    }

    bool rowIsCorrect = checkRowForWin();
    if (!rowIsCorrect) {
      startNewRow();
    }

    return true;
  }

//check if the current row when complete is correct
  bool checkRowForWin() {
    Guess guess = state.guesses.last;
    for (LetterStatus letterStatus in guess.letterMatch) {
      if (letterStatus != LetterStatus.correct) {
        return false;
      }
    }
    return true;
  }

  void startNewRow() {
    Guess guess = Guess.empty();

    List<Guess> guesses = state.guesses.toList();

    guesses.add(guess);

    if (mounted) {
      state = Game(
        gameWord: state.gameWord,
        guesses: guesses,
        guessCount: state.guessCount,
        gameStatus: state.gameStatus,
        activeRow: state.activeRow,
        activeCol: state.activeCol,
        animateRow: state.activeRow - 1,
      );
    }
  }

  Widget setLetterWidget({required int letterRow, required int letterColumn}) {
    Game game = state;

    //debugPrint('GameCount: ${game.guessCount} - letterRow: $letterRow');

    if (letterRow < game.activeRow) {
      return GameSquare(
        gameSquareValue: game.guesses[letterRow].guessWord[letterColumn],
        letterStatus: game.guesses[letterRow].letterMatch[letterColumn],
      );
    }

    if (letterRow > game.activeRow) {
      return const GameSquare(
        gameSquareValue: '',
        letterStatus: LetterStatus.unset,
      );
    }
    // debugPrint('Working Row-----');
    // debugPrint('GameCount: ${game.guessCount}, GuesseLength:${game.guesses.length} - letterRow: $letterRow');

    //Working Row -

    if (letterColumn == game.activeCol) {
      //  debugPrint('No Guessing in Working Row Row-----');
      return const GameSquareFocus();
    }

    return const GameSquare(
      gameSquareValue: '',
      letterStatus: LetterStatus.unset,
    );
  }

  void saveLetter({required String letter}) {
    Game game = state;
    int activeCol = game.activeCol;
    //If this is the start of a new
    List<String> currentGuess = game.guesses[game.activeRow].guessWord.toList();
    // for (String letter in currentGuess) {
    //   debugPrint(letter);
    // }

    //If already at last letter then can not change
    if (game.activeCol == 4 && currentGuess.length == 5) {
      return;
    }

    //Add this letter to the guess and then add to the square

    List<Guess> guesses = game.guesses;
    Guess newGuess = guesses.last;
    //newGuess.guessWord.removeLast();
    newGuess.guessWord.add(letter);
    String guessWordPrint = '';
    for (String letter in newGuess.guessWord) {
      guessWordPrint = guessWordPrint + letter;
    }
    debugPrint(guessWordPrint);
    guesses.removeLast();
    guesses.add(newGuess);

    if (activeCol < 4) {
      activeCol = activeCol + 1;
    }

    state = Game(
      gameWord: game.gameWord,
      guesses: guesses,
      guessCount: game.guessCount,
      gameStatus: game.gameStatus,
      activeRow: game.activeRow,
      activeCol: activeCol,
      animateRow: game.animateRow,
    );
  }
}
