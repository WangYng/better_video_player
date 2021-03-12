import 'package:better_video_player/src/core/better_video_player_controller.dart';
import 'package:better_video_player/src/core/better_video_player_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class BetterVideoPlayerWithControls extends StatefulWidget {
  final bool isFullScreen;

  const BetterVideoPlayerWithControls({Key key, @required this.isFullScreen})
      : super(key: key);

  @override
  _BetterVideoPlayerWithControlsState createState() =>
      _BetterVideoPlayerWithControlsState();
}

class _BetterVideoPlayerWithControlsState
    extends State<BetterVideoPlayerWithControls> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BetterVideoPlayerController>();

    return Container(
      color: Colors.black,
      child: Stack(
        overflow: Overflow.clip,
        fit: StackFit.expand,
        children: <Widget>[
          Offstage(
            offstage:
                controller.value?.videoPlayerController?.value?.initialized ??
                    false,
            child: controller.value.configuration.placeholder,
          ),
          Center(
            child: ClipRRect(
              child: AspectRatio(
                aspectRatio: BetterVideoPlayerUtils.aspectRatio(
                        controller.value?.videoPlayerController?.value) ??
                    (16.0 / 9.0),
                child:
                    controller.value.videoPlayerController?.value?.initialized ??
                            false
                        ? VideoPlayer(controller.value.videoPlayerController)
                        : const SizedBox(),
              ),
            ),
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
