import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player_example/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NormalPlayerPage extends StatefulWidget {
  @override
  _NormalPlayerPageState createState() => _NormalPlayerPageState();
}

class _NormalPlayerPageState extends State<NormalPlayerPage> {
  BetterVideoPlayerController _BetterVideoPlayerController;

  @override
  void initState() {
    _BetterVideoPlayerController = BetterVideoPlayerController.configuration(
      BetterVideoPlayerConfiguration(
        placeholder: CachedNetworkImage(
          imageUrl: kTestVideoThumbnail,
          fit: BoxFit.cover,
        ),
      ),
    );
    super.initState();
  }

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
                controller: _BetterVideoPlayerController,
                dataSource: BetterVideoPlayerDataSource(
                  BetterVideoPlayerDataSourceType.network,
                  kTestVideoUrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _BetterVideoPlayerController.dispose();
    super.dispose();
  }
}
