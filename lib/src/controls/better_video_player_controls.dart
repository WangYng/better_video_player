import 'dart:async';

import 'package:better_video_player/src/controls/progress/better_video_player_progress_widget.dart';
import 'package:better_video_player/src/core/better_video_player_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BetterVideoPlayerControls extends StatefulWidget {
  final bool isFullScreen;

  const BetterVideoPlayerControls({Key? key, required this.isFullScreen}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BetterVideoPlayerControlsState();
  }
}

class BetterVideoPlayerControlsState extends State<BetterVideoPlayerControls>
    with HideStuff<BetterVideoPlayerControls> {
  @override
  void initState() {
    super.initState();

    // 显示
    show(duration: Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BetterVideoPlayerController>();

    final isPlaying = controller.value.videoPlayerController?.value.isPlaying ?? false;
    if (isPlaying && isAlwaysShow()) {
      scheduleMicrotask(() => show(duration: Duration(seconds: 3)));
    } else if (!isPlaying && _isHide) {
      scheduleMicrotask(() => show());
    }

    return GestureDetector(
      onTap: () {
        if (_isHide) {
          show(duration: Duration(seconds: 3));
        }
      },
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isHide,
            child: Stack(
              children: [
                if (controller.value.videoPlayerController?.value.hasError ?? false) // 发生错误
                  buildError(_onRestart)
                else if (controller.value.isLoading) // 加载中
                  Center(child: buildLoading())
                else if (controller.value.isVideoFinish && !controller.value.configuration.looping) // 播放完成
                  buildReplay(_onPlayPause)
                else if (controller.value.wifiInterrupted) // wifi中断
                  buildWifiInterrupted(_onPlayPause)
                else if (!(controller.value.videoPlayerController?.value.isPlaying ?? false)) // 暂停
                  buildCenterPause(_onPlayPause)
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

  Widget buildTopBar(VoidCallback onTap) {
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
              ],
            ),
          ),
          child: Row(
            children: [
              buildPlayPause(_onPlayPause),
              Expanded(
                child: buildProgress(
                  show,
                  () => show(duration: Duration(seconds: 3)),
                ),
              ),
              if (controller.value.videoPlayerController != null)
                buildExpand(widget.isFullScreen ? _onReduceCollapse : _onExpandCollapse)
              else
                SizedBox(width: 9),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildError(VoidCallback onTap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: Colors.yellowAccent,
            size: 42,
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.black26,
              ),
              child: Text("restart", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpand(VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: widget.isFullScreen
            ? const Icon(
                Icons.fullscreen_exit,
                color: Colors.white,
              )
            : const Icon(
                Icons.fullscreen,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget buildPlayPause(VoidCallback onTap) {
    final controller = context.watch<BetterVideoPlayerController>();

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: controller.value.videoPlayerController?.value.isPlaying ?? false
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

  Widget buildWifiInterrupted(VoidCallback onTap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.black87,
            ),
            child: Text(
              "wifi interrupted",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCenterPause(VoidCallback onTap) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 60,
          ),
        ),
      ),
    );
  }

  Widget buildReplay(VoidCallback onTap) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26,
          ),
          child: const Icon(
            Icons.cached_rounded,
            color: Colors.white,
            size: 60,
          ),
        ),
      ),
    );
  }

  Widget buildProgress(Function onDragStart, Function onDragEnd) {
    return Container(
      constraints: BoxConstraints.expand(height: 36),
      child: BetterVideoPlayerProgressWidget(
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
      ),
    );
  }

  void _onExpandCollapse() {
    hide();
    context.read<BetterVideoPlayerController>().enterFullScreen();
  }

  void _onReduceCollapse() {
    hide();
    context.read<BetterVideoPlayerController>().exitFullScreen();
  }

  void _onPlayPause() {
    final controller = context.read<BetterVideoPlayerController>();

    setState(() {
      if (controller.value.videoPlayerController?.value.isPlaying ?? false) {
        controller.value = controller.value.copyWith(isPauseFromUser: true);

        controller.pause();
      } else {
        controller.value = controller.value.copyWith(isPauseFromUser: false);

        if (controller.value.videoPlayerController?.value.isInitialized ?? false) {
          if (controller.value.isVideoFinish) {
            controller.seekTo(const Duration());
          }
          controller.play();
        }
      }
    });
  }

  void _onRestart() {
    final controller = context.read<BetterVideoPlayerController>();
    controller.restart();
  }
}

mixin HideStuff<T extends StatefulWidget> on State<T> {
  bool _isHide = true;
  Timer? _hideTimer;

  void show({Duration? duration}) {
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

  void hide() {
    _hideTimer?.cancel();
    setState(() {
      _isHide = true;
    });
  }

  bool isAlwaysShow() {
    return !_isHide && !(_hideTimer?.isActive ?? false);
  }
}
