import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wordle2/controllers/game_controller.dart';
import 'package:wordle2/models/game_model.dart';

class GameSquareFocus extends ConsumerWidget {
  const GameSquareFocus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.white)),
        width: 40,
        height: 40,
        child: Material(
          child: TextField(
            autofocus: true,
            onChanged: (value) {
              if (value.length == 1) {
                ref.read(gameController.notifier).saveLetter(letter: value);
              }
            },
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
