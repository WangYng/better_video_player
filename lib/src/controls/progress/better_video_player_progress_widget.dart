import 'package:better_video_player/src/controls/progress/better_video_player_progress_bar.dart';
import 'package:better_video_player/src/controls/progress/better_video_player_progress_colors.dart';
import 'package:better_video_player/src/core/better_video_player_controller.dart';
import 'package:better_video_player/src/core/better_video_player_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 播放控制器的播放进度控件
class BetterVideoPlayerProgressWidget extends StatefulWidget {
  /// 拖动开始
  final Function onDragStart;

  /// 拖动结束
  final Function onDragEnd;

  const BetterVideoPlayerProgressWidget({
    Key key,
    @required this.onDragStart,
    @required this.onDragEnd,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BetterVideoPlayerProgressWidgetState();
  }
}

class BetterVideoPlayerProgressWidgetState
    extends State<BetterVideoPlayerProgressWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildPosition(),
        Expanded(child: buildProgressBar()),
        buildDuration(),
      ],
    );
  }

  Widget buildPosition() {
    final controller = context.watch<BetterVideoPlayerController>();
    final position = controller.value.videoPlayerController?.value?.position ??
        Duration.zero;
    return Text(
      '${BetterVideoPlayerUtils.formatDuration(position)}',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget buildDuration() {
    final controller = context.watch<BetterVideoPlayerController>();
    final duration = controller.value.videoPlayerController?.value?.duration ??
        Duration.zero;
    return Text(
      '${BetterVideoPlayerUtils.formatDuration(duration)}',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
    );
  }
  
  Widget buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: BetterVideoPlayerProgressBar(
        onDragStart: widget.onDragStart,
        onDragEnd: widget.onDragEnd,
        colors: BetterVideoPlayerProgressColors(
          playedColor: Color(0xFFFF671F),
          handleColor: Colors.white,
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white38,
        ),
      ),
    );
  }
}
