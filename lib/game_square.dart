import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wordle2/models/game_model.dart';

class GameSquare extends ConsumerWidget {
  final String gameSquareValue;
  final LetterStatus letterStatus;
  const GameSquare({super.key, required this.gameSquareValue, required this.letterStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(color: letterStatus.squareColor, border: Border.all(color: Colors.white)),
        width: 40,
        height: 40,
        child: Text(
          gameSquareValue,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
