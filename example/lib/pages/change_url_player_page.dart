import 'dart:async';

import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player_example/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeUrlPlayerPage extends StatefulWidget {
  @override
  _ChangeUrlPlayerPageState createState() => _ChangeUrlPlayerPageState();
}

class _ChangeUrlPlayerPageState extends State<ChangeUrlPlayerPage> {
  final BetterVideoPlayerController controller = BetterVideoPlayerController();
  late StreamSubscription playerEventSubscription;

  int currentIndex = 0;
  List<String> playlist = [kTestVideoUrl, kPortraitVideoUrl];
  List<String> placeholderList = [kTestVideoThumbnail, kPortraitVideoThumbnail];

  @override
  void initState() {
    super.initState();

    playerEventSubscription = controller.playerEventStream.listen((event) {
      print("wang $event");
    });
  }

  @override
  void dispose() {
    controller.dispose();
    playerEventSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("playlist"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Playlist player",
                style: TextStyle(fontSize: 16),
              ),
            ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: BetterVideoPlayer(
                controller: controller,
                configuration: BetterVideoPlayerConfiguration(
                  placeholder: Image.network(
                    placeholderList[currentIndex],
                    fit: BoxFit.contain,
                  ),
                ),
                dataSource: BetterVideoPlayerDataSource(
                  BetterVideoPlayerDataSourceType.network,
                  playlist[currentIndex],
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () {
                setState(() {
                  if (currentIndex == playlist.length - 1) {
                    currentIndex = 0;
                  } else {
                    currentIndex++;
                  }
                });
              },
              child: Text("Change Video Url"),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.green,
              margin: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "g\nr\ne\ne\nn",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
