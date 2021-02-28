import 'package:better_video_player_example/pages/welcome_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.green,
      ),
      home: WelcomePage(),
    );
  }
}
