import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wordle2/controllers/game_controller.dart';
import 'package:wordle2/game_square.dart';
import 'package:wordle2/models/game_model.dart';

class GameRow extends ConsumerWidget {
  final int guessNumber;
  const GameRow({super.key, required this.guessNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Game game = ref.watch(gameController);

    List<Widget> generateGuessRow() {
      //debugPrint('generateGuessRow executing');
      List<Widget> gameRow = [];

      for (int i = 0; i < 5; i++) {
        gameRow.add(ref.read(gameController.notifier).setLetterWidget(letterRowIndex: guessNumber, letterColumnIndex: i));
      }

      return gameRow;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: generateGuessRow(),
    );
  }
}
