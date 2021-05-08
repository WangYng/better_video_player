import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player_example/constants.dart';
import 'package:flutter/material.dart';

class NormalPlayerPage extends StatefulWidget {
  @override
  _NormalPlayerPageState createState() => _NormalPlayerPageState();
}

class _NormalPlayerPageState extends State<NormalPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Normal player"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Normal player with configuration managed by developer.",
                style: TextStyle(fontSize: 16),
              ),
            ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: BetterVideoPlayer(
                controller: BetterVideoPlayerController.configuration(
                  BetterVideoPlayerConfiguration(
                    placeholder: Image.network(
                      kTestVideoThumbnail,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                dataSource: BetterVideoPlayerDataSource(
                  BetterVideoPlayerDataSourceType.network,
                  kTestVideoUrl,
                ),
              ),
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
