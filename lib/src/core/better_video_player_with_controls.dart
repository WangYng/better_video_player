import 'package:better_video_player/src/core/better_video_player_controller.dart';
import 'package:better_video_player/src/core/better_video_player_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class BetterVideoPlayerWithControls extends StatefulWidget {
  final bool isFullScreen;

  const BetterVideoPlayerWithControls({Key? key, required this.isFullScreen}) : super(key: key);

  @override
  _BetterVideoPlayerWithControlsState createState() => _BetterVideoPlayerWithControlsState();
}

class _BetterVideoPlayerWithControlsState extends State<BetterVideoPlayerWithControls> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BetterVideoPlayerController>();

    return Container(
      color: Colors.black,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: ClipRRect(
              child: AspectRatio(
                aspectRatio:
                    BetterVideoPlayerUtils.aspectRatio(controller.value.videoPlayerController?.value) ?? (16.0 / 9.0),
                child: controller.value.videoPlayerController?.value.isInitialized ?? false
                    ? VideoPlayer(controller.value.videoPlayerController!)
                    : const SizedBox(),
              ),
            ),
          ),
          Offstage(
            offstage: (controller.videoPlayerValue?.isInitialized ?? false) &&
                (controller.videoPlayerValue?.position ?? Duration.zero) > Duration.zero,
            child: controller.value.configuration.placeholder,
          ),
          if (widget.isFullScreen)
            controller.value.configuration.fullScreenControls
          else
            controller.value.configuration.controls,
        ],
      ),
    );
  }
}
