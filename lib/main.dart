import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wordle2/game_landing.dart';
import 'board.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(ProviderScope(child: Wordle2()));
}

class Wordle2 extends StatelessWidget {
  Wordle2({Key? key}) : super(key: key);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'game_landing',
        builder: (context, state) => const GameLanding(),
      ),
      GoRoute(
        path: '/board',
        name: 'board',
        builder: (context, state) => const Board(),
      ),
    ],
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
    );
  }
}
