import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wordle2/game_row.dart';
import 'package:wordle2/game_row_animated.dart';
import 'package:wordle2/models/game_model.dart';
import 'controllers/game_controller.dart';

class Board extends ConsumerWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    Game game = ref.watch(gameController);

    List<Widget> generateBoard() {
      List<Widget> gameRowBuilder = [];
      for (int i = 0; i < 5; i++) {
        //TODO add gameRow Animated Builder
        if (i == game.animateRow) {
          gameRowBuilder.add(const GameRowAnimated());
        } else {
          gameRowBuilder.add(GameRow(guessNumber: i));
        }
      }

      return gameRowBuilder;
    }

    return Material(
      child: Scaffold(
        body: Container(
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            maxHeight: size.height - 182,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: generateBoard(),
              ),
              game.submitAvailable
                  ? TextButton(
                      onPressed: () {
                        ref.read(gameController.notifier).saveGuess();
                      },
                      child: const Text('Submit'))
                  : const Text(
                      'not avaialbe',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
