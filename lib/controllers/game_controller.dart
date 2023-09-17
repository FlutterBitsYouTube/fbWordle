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
          gameStatus: GameStatus.unfinished,
          animateRowIndex: -1,
          submitAvailable: false,
        ));

  void initializeGame({required String newGameWord}) {
    if (newGameWord.length == 5) {
      debugPrint('Invalid Game Work: $newGameWord');
    }

    List<String> gameWord = newGameWord.split('');

    Game newGame = Game(
      gameWord: gameWord,
      guesses: [],
      gameStatus: GameStatus.unfinished,
      animateRowIndex: -1,
      submitAvailable: false,
    );
    state = newGame;

    startNewRow();
  }

  bool submitGuess() {
    debugPrint('SaveGuess');
    Game game = state;
    Guess currentSubmittedGuess = game.guesses[getActiveRow()];

    final List<String> gameWord = game.gameWord.toList();

    for (int i = 0; i < game.guesses.length - 1; i++) {
      //If a repeat guess then invalid and have the user guess again.
      if (game.guesses[i].guessWord == currentSubmittedGuess.guessWord) {
        return false;
      }
    }

    //Mark all correct answers
    for (int i = 0; i < 5; i++) {
      //debugPrint('gameWord[i]: ${gameWord[i]} currentGuess: ${currentSubmittedGuess.guessWord[i]}');
      if (currentSubmittedGuess.guessWord[i] == gameWord[i]) {
        debugPrint('gameWord[i]: ${gameWord[i]} currentGuess: ${currentSubmittedGuess.guessWord[i]}');
        currentSubmittedGuess.letterMatch[i] = LetterStatus.correct;
        //Make sure this letter can not be matched again.
        gameWord[i] = '_';
      }
    }
    //Mark all answers that are in the game but in a different location or as an invalid letter
    for (int i = 0; i < 5; i++) {
      if (currentSubmittedGuess.letterMatch[i] == LetterStatus.unset) {
        int foundLetterButNotMatch = gameWord.indexOf(currentSubmittedGuess.guessWord[i]);
        currentSubmittedGuess.letterMatch[i] = LetterStatus.invalid;
        debugPrint('currentGuess: ${currentSubmittedGuess.guessWord[i]} Found:$foundLetterButNotMatch');
        debugPrint('GameWord ${gameWord.toString()} ');
        //If the letter is found in the game word but not an exact match
        if (foundLetterButNotMatch > -1) {
          //debugPrint('currentGuess: ${currentSubmittedGuess.guessWord[i]} Found:$foundLetterButNotMatch');
          currentSubmittedGuess.letterMatch[i] = LetterStatus.wrongLocation;
          gameWord[foundLetterButNotMatch] = '_';
        }
      }
    }

    //Replace the guess with a new guess with status set for each letter.
    List<Guess> guesses = game.guesses.toList();

    guesses.removeLast();
    guesses.add(currentSubmittedGuess);

    state = Game(
      gameWord: game.gameWord,
      guesses: guesses,
      gameStatus: game.gameStatus,
      animateRowIndex: game.animateRowIndex,
      submitAvailable: false,
    );

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
    debugPrint('Game Complete Winner');
    return true;
  }

  void startNewRow() {
    Guess guess = Guess.empty();

    List<Guess> guesses = state.guesses.toList();

    guesses.add(guess);
    debugPrint(('Guesses.length ${guesses.length}'));

    state = Game(
      gameWord: state.gameWord,
      guesses: guesses,
      gameStatus: state.gameStatus,
      animateRowIndex: state.animateRowIndex,
      submitAvailable: false,
    );
  }

  Widget setLetterWidget({required int letterRowIndex, required int letterColumnIndex}) {
    Game game = state;
    int activeRowIndex = getActiveRow();
    int activeColIndex = getActiveCol();
    //debugPrint('Drawing: RowIndex $letterRowIndex - ColIndex $letterColumnIndex');
    //debugPrint('Drawing: ActiveRow $activeRowIndex - ActiveCol $activeColIndex');
    //debugPrint('GameCount: ${game.guessCount} - letterRow: $letterRow');

    if (letterRowIndex < activeRowIndex) {
      return GameSquare(
        gameSquareValue: game.guesses[letterRowIndex].guessWord[letterColumnIndex],
        letterStatus: game.guesses[letterRowIndex].letterMatch[letterColumnIndex],
      );
    }

    if (letterRowIndex > activeRowIndex) {
      return const GameSquare(
        gameSquareValue: '',
        letterStatus: LetterStatus.unset,
      );
    }
    // debugPrint('Working Row-----');
    // debugPrint('GameCount: ${game.guessCount}, GuesseLength:${game.guesses.length} - letterRow: $letterRow');

    //Working Row -
    if (activeColIndex == 5 && letterColumnIndex == 4) {
      debugPrint('Focus RowIndex $letterRowIndex - ColIndex $letterColumnIndex');
      return const GameSquareFocus();
    }
    if (letterColumnIndex == activeColIndex) {
      debugPrint('Focus RowIndex $letterRowIndex - ColIndex $letterColumnIndex');
      return const GameSquareFocus();
    }
    if (letterColumnIndex < activeColIndex) {
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
    int activeColIndex = getActiveCol();
    int activeRowIndex = getActiveRow();
    //If this is the start of a new
    List<String> currentGuess = game.guesses[activeRowIndex].guessWord.toList();
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

    if (activeColIndex < 5) {
      activeColIndex = activeColIndex + 1;
    }
    if (activeColIndex == 5) {
      submitAvailable = true;
    }

    if (mounted) {
      state = Game(
        gameWord: game.gameWord,
        guesses: game.guesses,
        gameStatus: game.gameStatus,
        animateRowIndex: game.animateRowIndex,
        submitAvailable: submitAvailable,
      );
    }

    debugPrint('save complete ${newGuess.guessWord.toString()} activeCol:$activeColIndex');
  }

  void removeLetter() {
    debugPrint('deletetriggered');
    Game game = state;
    //int activeColIndex = game.activeColIndex;
    bool submitAvailable = false;

    Guess guess = game.guesses.last;
    //debugPrint('deleteing letter in ${guess.guessWord.toString()} activeColIndex:$activeColIndex');

    guess.guessWord.removeLast();

    saveUpdatedGuess(guess: guess);

    //activeColIndex = activeColIndex - 1;

    if (mounted) {
      state = Game(
        gameWord: game.gameWord,
        guesses: game.guesses,
        gameStatus: game.gameStatus,
        animateRowIndex: game.animateRowIndex,
        submitAvailable: submitAvailable,
      );
    }

    //debugPrint('deleteing done now ${guess.guessWord.toString()} activeColIndex:$activeColIndex');
  }

  int getActiveRow() {
    return state.guesses.length - 1;
  }

  int getActiveCol() {
    if (state.guesses.last.guessWord.isEmpty) {
      return 0;
    }
    return state.guesses[getActiveRow()].guessWord.length;
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
        gameStatus: game.gameStatus,
        animateRowIndex: game.animateRowIndex,
        submitAvailable: game.submitAvailable,
      );
    }
  }
}
