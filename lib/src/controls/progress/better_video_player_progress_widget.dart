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

  /// 是否是全屏
  final bool isFullScreen;

  const BetterVideoPlayerProgressWidget({
    Key key,
    @required this.onDragStart,
    @required this.onDragEnd,
    @required this.isFullScreen,
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
        if (widget.isFullScreen)
          _buildPosition()
        else
          _buildPositionAndDuration(),
        Expanded(child: _buildProgressBar()),
        if (widget.isFullScreen) _buildDuration() else const SizedBox(),
      ],
    );
  }

  Widget _buildPosition() {
    final controller = context.watch<BetterVideoPlayerController>();
    final position = controller.value.videoPlayerController?.value?.position ??
        Duration.zero;
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Text(
        '${BetterVideoPlayerUtils.formatDuration(position)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildDuration() {
    final controller = context.watch<BetterVideoPlayerController>();
    final duration =
        controller.value.videoPlayerController?.value?.duration ?? Duration.zero;
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Text(
        '${BetterVideoPlayerUtils.formatDuration(duration)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildPositionAndDuration() {
    final controller = context.watch<BetterVideoPlayerController>();
    final position = controller.value.videoPlayerController?.value?.position ??
        Duration.zero;
    final duration = controller.value.videoPlayerController?.value?.duration ??
        Duration.zero;
    return Padding(
      padding: const EdgeInsets.only(),
      child: Text(
        '${BetterVideoPlayerUtils.formatDuration(position)}/${BetterVideoPlayerUtils.formatDuration(duration)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: BetterVideoPlayerProgressBar(
        onDragStart: widget.onDragStart,
        onDragEnd: widget.onDragEnd,
        colors: BetterVideoPlayerProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          bufferedColor: Colors.white70,
          backgroundColor: Colors.white60,
        ),
      ),
    );
  }
}
