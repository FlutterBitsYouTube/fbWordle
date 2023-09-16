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
          activeRowIndex: 0,
          activeColIndex: 0,
          animateRowIndex: -1,
          submitAvailable: false,
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
        activeRowIndex: 1,
        activeColIndex: 0,
        animateRowIndex: -1,
        submitAvailable: false,
      );

      if (mounted) {
        state = newGame;
      }
    }
  }

  bool saveGuess() {
    debugPrint('SaveGuess');
    Game game = state;
    Guess currentGuess = game.guesses[game.activeRowIndex];

    final List<String> gameWord = game.gameWord.toList();
    int guessCount = game.guessCount;
    List<LetterStatus> letterMatch = [
      LetterStatus.unset,
      LetterStatus.unset,
      LetterStatus.unset,
      LetterStatus.unset,
      LetterStatus.unset,
    ];

    for (int i = 0; i < game.guesses.length - 1; i++) {
      //If a repeat guess then invalid and have the user guess again.
      if (game.guesses[i].guessWord == currentGuess.guessWord) {
        return false;
      }
    }
    //Mark all correct answers
    for (int i = 0; i < 5; i++) {
      debugPrint('gameWord[i]: ${gameWord[i]} currentGuess: ${currentGuess.guessWord[i]}');
      if (currentGuess.guessWord[i] == gameWord[i]) {
        debugPrint('guess letter correct ${currentGuess.guessWord[i]}');
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
        activeRowIndex: game.activeRowIndex,
        activeColIndex: game.activeColIndex,
        animateRowIndex: game.activeRowIndex,
        submitAvailable: false,
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
    debugPrint(('Guesses.length ${guesses.length}'));

    if (mounted) {
      state = Game(
        gameWord: state.gameWord,
        guesses: guesses,
        guessCount: state.guessCount,
        gameStatus: state.gameStatus,
        activeRowIndex: state.activeRowIndex + 1,
        activeColIndex: 0,
        animateRowIndex: state.activeRowIndex,
        submitAvailable: false,
      );
    }
  }

  Widget setLetterWidget({required int letterRowIndex, required int letterColumnIndex}) {
    Game game = state;
    //debugPrint('Drawing: RowIndex $letterRowIndex - ColIndex $letterColumnIndex');
    //debugPrint('GameCount: ${game.guessCount} - letterRow: $letterRow');

    if (letterRowIndex < game.activeRowIndex) {
      return GameSquare(
        gameSquareValue: game.guesses[letterRowIndex].guessWord[letterColumnIndex],
        letterStatus: game.guesses[letterRowIndex].letterMatch[letterColumnIndex],
      );
    }

    if (letterRowIndex > game.activeRowIndex) {
      return const GameSquare(
        gameSquareValue: '',
        letterStatus: LetterStatus.unset,
      );
    }
    // debugPrint('Working Row-----');
    // debugPrint('GameCount: ${game.guessCount}, GuesseLength:${game.guesses.length} - letterRow: $letterRow');

    //Working Row -
    if (game.activeColIndex == 5 && letterColumnIndex == 4) {
      debugPrint('Focus RowIndex $letterRowIndex - ColIndex $letterColumnIndex');
      return const GameSquareFocus();
    }
    if (letterColumnIndex == game.activeColIndex) {
      debugPrint('Focus RowIndex $letterRowIndex - ColIndex $letterColumnIndex');
      return const GameSquareFocus();
    }
    if (letterColumnIndex < game.activeColIndex) {
      //debugPrint('ActiveRowWord: ${game.guesses[letterRow].guessWord}');
      //debugPrint('activerow show saved letter--row$letterRow- col:$letterColumn--${game.guesses[letterRow].guessWord[letterColumn]}');
      return GameSquare(
        gameSquareValue: game.guesses[letterRowIndex].guessWord[letterColumnIndex],
        letterStatus: LetterStatus.unset,
      );
    }
    //debugPrint('AddingActiveRow GameSquare');
    return const GameSquare(
      gameSquareValue: '',
      letterStatus: LetterStatus.unset,
    );
  }

  void addLetter({required String letter}) {
    Game game = state;
    int activeColIndex = game.activeColIndex;
    //If this is the start of a new
    List<String> currentGuess = game.guesses[game.activeRowIndex].guessWord.toList();
    // for (String letter in currentGuess) {
    //   debugPrint(letter);
    // }

    //If already at last letter then can not change
    if (activeColIndex == 5 && currentGuess.length == 5) {
      state = state;
      return;
    }

    //Add this letter to the guess and then add to the square

    List<Guess> guesses = game.guesses;
    Guess newGuess = guesses.last;
    bool submitAvailable = false;

    newGuess.guessWord.add(letter);
    debugPrint('saving letter :$letter ${newGuess.guessWord.toString()} activeCol:$activeColIndex');

    saveUpdatedGuess(guess: newGuess);

    if (activeColIndex == 5) {
      submitAvailable = true;
    }
    if (activeColIndex < 5) {
      activeColIndex = activeColIndex + 1;
    }

    if (mounted) {
      state = Game(
        gameWord: game.gameWord,
        guesses: game.guesses,
        guessCount: game.guessCount,
        gameStatus: game.gameStatus,
        activeRowIndex: game.activeRowIndex,
        activeColIndex: activeColIndex,
        animateRowIndex: game.animateRowIndex,
        submitAvailable: submitAvailable,
      );
    }

    debugPrint('save complete ${newGuess.guessWord.toString()} activeCol:$activeColIndex');
  }

  void removeLetter() {
    debugPrint('deletetriggered');
    Game game = state;
    int activeColIndex = game.activeColIndex;
    bool submitAvailable = false;

    Guess guess = game.guesses.last;
    debugPrint('deleteing letter in ${guess.guessWord.toString()} activeColIndex:$activeColIndex');

    guess.guessWord.removeLast();

    saveUpdatedGuess(guess: guess);

    activeColIndex = activeColIndex - 1;

    if (mounted) {
      state = Game(
        gameWord: game.gameWord,
        guesses: game.guesses,
        guessCount: game.guessCount,
        gameStatus: game.gameStatus,
        activeRowIndex: game.activeRowIndex,
        activeColIndex: activeColIndex,
        animateRowIndex: game.animateRowIndex,
        submitAvailable: submitAvailable,
      );
    }

    debugPrint('deleteing done now ${guess.guessWord.toString()} activeColIndex:$activeColIndex');
  }

  void saveUpdatedGuess({required Guess guess}) {
    Game game = state;
    List<Guess> guesses = game.guesses;

    guesses.removeLast();
    guesses.add(guess);

    if (mounted) {
      state = Game(
        gameWord: game.gameWord,
        guesses: guesses,
        guessCount: game.guessCount,
        gameStatus: game.gameStatus,
        activeRowIndex: game.activeRowIndex,
        activeColIndex: game.activeColIndex,
        animateRowIndex: game.animateRowIndex,
        submitAvailable: game.submitAvailable,
      );
    }
  }
}
