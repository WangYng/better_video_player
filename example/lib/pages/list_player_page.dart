import 'dart:async';

import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player_example/constants.dart';
import 'package:flutter/material.dart';

class ListPlayerPage extends StatefulWidget {
  @override
  _ListPlayerPageState createState() => _ListPlayerPageState();
}

class _ListPlayerPageState extends State<ListPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Normal player"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "100 video player.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: BetterVideoPlayer(
                    controller: BetterVideoPlayerController.configuration(
                      BetterVideoPlayerConfiguration(
                        placeholder: Image.network(
                          kTestVideoThumbnail,
                          fit: BoxFit.contain,
                        ),
                        autoPlay: false,
                        autoPlayWhenResume: false,
                      ),
                    ),
                    dataSource: BetterVideoPlayerDataSource(
                      BetterVideoPlayerDataSourceType.network,
                      kTestVideoUrl,
                    ),
                  ),
                );
              },
              itemCount: 100,
            ),
          ),
        ],
      ),
    );
  }
}
