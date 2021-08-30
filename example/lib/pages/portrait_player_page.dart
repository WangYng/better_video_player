import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player_example/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PortraitPlayerPage extends StatefulWidget {
  @override
  _PortraitPlayerPageState createState() => _PortraitPlayerPageState();
}

class _PortraitPlayerPageState extends State<PortraitPlayerPage> {
  late BetterVideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = BetterVideoPlayerController.configuration(
      BetterVideoPlayerConfiguration(
        placeholder: Image.network(
          kPortraitVideoThumbnail,
          fit: BoxFit.contain,
        ),
        controls: const _CustomVideoPlayerControls(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portrait player"),
      ),
      body: BetterVideoPlayer(
        controller: controller,
        dataSource: BetterVideoPlayerDataSource(
          BetterVideoPlayerDataSourceType.network,
          kPortraitVideoUrl,
        ),
      ),
    );
  }
}

class _CustomVideoPlayerControls extends StatefulWidget {
  const _CustomVideoPlayerControls({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomVideoPlayerControlsState();
  }
}

class _CustomVideoPlayerControlsState extends State<_CustomVideoPlayerControls> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BetterVideoPlayerController>();

    return InkWell(
      onTap: _onPlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller.value.videoPlayerController?.value.hasError ?? false)
            buildError()
          else if (controller.value.isLoading)
            Center(child: buildLoading())
          else if (!(controller.value.videoPlayerController?.value.isPlaying ?? false))
            Stack(children: [
              Center(child: buildPlayPause()),
              Align(alignment: Alignment.bottomCenter, child: buildProgress()),
            ])
          else
            SizedBox(),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: Colors.yellowAccent,
            size: 42,
          ),
          Text(
            "无法播放视频",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildPlayPause() {
    return const Icon(
      Icons.play_arrow,
      color: Colors.white,
      size: 60,
    );
  }

  Widget buildProgress() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      constraints: BoxConstraints.expand(height: 44),
      child: BetterVideoPlayerProgressWidget(
        onDragStart: () => null,
        onDragEnd: () => null,
      ),
    );
  }

  void _onPlayPause() {
    final controller = context.read<BetterVideoPlayerController>();

    setState(() {
      if (controller.value.videoPlayerController?.value.isPlaying ?? false) {
        controller.pause();
      } else {
        if (controller.value.videoPlayerController?.value.isInitialized ?? false) {
          if (controller.value.isVideoFinish) {
            controller.seekTo(const Duration());
          }
          controller.play();
        }
      }
    });
  }
}
