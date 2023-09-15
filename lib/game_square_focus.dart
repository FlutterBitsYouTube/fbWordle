import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wordle2/controllers/game_controller.dart';
import 'package:wordle2/models/game_model.dart';
import 'package:flutter/services.dart';

class GameSquareFocus extends ConsumerWidget {
  const GameSquareFocus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Game game = ref.watch(gameController);

    bool textFieldEnabled = true;
    if (game.guesses.last.guessWord.length == 5) {
      textFieldEnabled = false;
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.white)),
        width: 60,
        height: 60,
        child: Material(
          child: RawKeyboardListener(
            focusNode: FocusNode(
              onKeyEvent: (node, event) {
                if (!textFieldEnabled) {
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
            ),
            onKey: (event) {
              debugPrint(event.logicalKey.keyLabel);

              if (event.runtimeType.toString() == 'RawKeyDownEvent' && event.logicalKey == LogicalKeyboardKey.backspace) {
                debugPrint('delete');
              }
            },
            child: TextField(
              textAlign: TextAlign.center,
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                fillColor: Colors.black,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white, // Set the border color to white
                    width: 0.0, // Set the border width
                  ),
                ),
              ),
              autofocus: true,
              onChanged: (value) {
                if (value.length == 1) {
                  String upperCase = value.toUpperCase();
                  debugPrint('save letter');
                  ref.read(gameController.notifier).saveLetter(letter: upperCase);
                }
              },
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
