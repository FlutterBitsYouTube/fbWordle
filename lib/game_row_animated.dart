import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import './game_square.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'controllers/game_controller.dart';
import 'models/game_model.dart';
import './game_square.dart';

// ignore_for_file: prefer_const_constructors
class GameRowAnimated extends ConsumerWidget {
  const GameRowAnimated({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int delay = 1000;
    List<Widget> animatedRow = [];
    Game game = ref.watch(gameController);
    for (int i = 0; i < 5; i++) {
      animatedRow.add(
        FlipCard(
          autoFlipDuration: Duration(milliseconds: delay),
          front: GameSquare(gameSquareValue: game.guesses[game.animateRowIndex].guessWord[i], letterStatus: game.guesses[game.animateRowIndex].letterMatch[i]),
          back: GameSquare(gameSquareValue: game.guesses[game.animateRowIndex].guessWord[i], letterStatus: game.guesses[game.animateRowIndex].letterMatch[i]),
        ),
      );
      delay = delay + 500;
    }

    return Center(
      child: SizedBox(
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: animatedRow,
        ),
      ),
    );
  }
}
