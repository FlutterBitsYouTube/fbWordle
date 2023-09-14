import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wordle2/controllers/game_controller.dart';

class GameLanding extends ConsumerWidget {
  const GameLanding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Container(
                child: GestureDetector(
                  child: const Text(
                    'Play',
                    style: TextStyle(color: Colors.white, fontSize: 50),
                  ),
                  onTap: () {
                    debugPrint('Pressed');
                    ref.read(gameController.notifier).initializeGame(newGameWord: 'SPAIN');
                    context.goNamed('board');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
