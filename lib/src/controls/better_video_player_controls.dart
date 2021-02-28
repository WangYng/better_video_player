import 'dart:async';

import 'package:better_video_player/src/controls/progress/better_video_player_progress_widget.dart';
import 'package:better_video_player/src/core/better_video_player_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BetterVideoPlayerControls extends StatefulWidget {
  final bool isFullScreen;

  const BetterVideoPlayerControls(
      {Key key, @required this.isFullScreen})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BetterVideoPlayerControlsState();
  }
}

class _BetterVideoPlayerControlsState
    extends State<BetterVideoPlayerControls>
    with _HideStuff<BetterVideoPlayerControls> {
  @override
  void initState() {
    super.initState();

    // 显示
    _show(duration: Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BetterVideoPlayerController>();

    return GestureDetector(
      onTap: () {
        if (_isHide) {
          _show(duration: Duration(seconds: 3));
        }
      },
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isHide,
            child: Stack(
              children: [
                if (controller.value.isLoading) // 加载中
                  Center(child: buildLoading())
                else
                  const SizedBox(),
                if (controller.value.videoPlayerController?.value?.hasError ??
                    false) // 发生错误
                  buildError()
                else
                  const SizedBox(),
                buildBottomBar(),
              ],
            ),
          ),
          buildTopBar(_onReduceCollapse),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Widget buildTopBar(Function onTap) {
    if (widget.isFullScreen)
      return Align(
        alignment: Alignment.topLeft,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Container(
            height: 44,
            width: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      );
    else
      return SizedBox();
  }

  Widget buildLoading() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
    );
  }

  Widget buildBottomBar() {
    final controller = context.watch<BetterVideoPlayerController>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedOpacity(
        opacity: !_isHide ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: Container(
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
          child: Row(
            children: [
              buildPlayPause(_onPlayPause),
              Expanded(
                child: buildProgress(
                  _show,
                  () => _show(duration: Duration(seconds: 3)),
                ),
              ),
              if (controller.value.videoPlayerController != null)
                buildExpand(
                    widget.isFullScreen ? _onReduceCollapse : _onExpandCollapse)
              else
                SizedBox(),
            ],
          ),
        ),
      ),
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

  Widget buildExpand(Function onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: const Icon(
          Icons.fullscreen,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildPlayPause(Function onTap) {
    final controller = context.watch<BetterVideoPlayerController>();

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: controller.value.videoPlayerController?.value?.isPlaying ?? false
          ? SizedBox(
              width: 44,
              height: 44,
              child: const Icon(
                Icons.pause,
                color: Colors.white,
              ),
            )
          : SizedBox(
              width: 44,
              height: 44,
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget buildProgress(Function onDragStart, Function onDragEnd) {
    return Container(
      constraints: BoxConstraints.expand(height: 44),
      child: BetterVideoPlayerProgressWidget(
        isFullScreen: widget.isFullScreen,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
      ),
    );
  }

  void _onExpandCollapse() {
    _hide();
    context.read<BetterVideoPlayerController>().enterFullScreen();
  }

  void _onReduceCollapse() {
    _hide();
    context.read<BetterVideoPlayerController>().exitFullScreen();
  }

  void _onPlayPause() {
    final controller = context.read<BetterVideoPlayerController>();

    setState(() {
      if (controller.value?.videoPlayerController?.value?.isPlaying ?? false) {
        _show();
        controller.pause();
      } else {
        _show(duration: Duration(seconds: 3));

        if (controller.value?.videoPlayerController?.value?.initialized ??
            false) {
          if (controller.value.isVideoFinish) {
            controller.seekTo(const Duration());
          }
          controller.play();
        }
      }
    });
  }
}

mixin _HideStuff<T extends StatefulWidget> on State<T> {
  bool _isHide = true;
  Timer _hideTimer;

  void _show({Duration duration}) {
    _hideTimer?.cancel();
    if (duration != null) {
      _hideTimer = Timer(duration, () {
        setState(() {
          _isHide = true;
        });
      });
    }

    setState(() {
      _isHide = false;
    });
  }

  void _hide() {
    _hideTimer?.cancel();
    setState(() {
      _isHide = true;
    });
  }
}
