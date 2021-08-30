import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player_example/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomPlayerPage extends StatefulWidget {
  @override
  _CustomPlayerPageState createState() => _CustomPlayerPageState();
}

class _CustomPlayerPageState extends State<CustomPlayerPage> {

  late final BetterVideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = BetterVideoPlayerController.configuration(
      BetterVideoPlayerConfiguration(
        placeholder: Image.network(
          kTestVideoThumbnail,
          fit: BoxFit.contain,
        ),
        controls: _CustomControls(isFullScreen: false),
        fullScreenControls: _CustomControls(isFullScreen: true),
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
        title: Text("Custom player"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Custom player with configuration managed by developer.",
                style: TextStyle(fontSize: 16),
              ),
            ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: BetterVideoPlayer(
                controller: controller,
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

class _CustomControls extends BetterVideoPlayerControls {
  final bool isFullScreen;

  const _CustomControls({Key? key, required this.isFullScreen}) : super(key: key, isFullScreen: isFullScreen);

  @override
  State<StatefulWidget> createState() {
    return _CustomControlsState();
  }
}

class _CustomControlsState extends BetterVideoPlayerControlsState {
  /// 暂停播放按钮
  Widget buildPlayPause(Function() onTap) {
    final controller = context.watch<BetterVideoPlayerController>();
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      onPressed: onTap,
      child: controller.value.videoPlayerController?.value?.isPlaying ?? false
          ? Image.asset("images/pause.png", width: 26, height: 26)
          : Image.asset("images/play.png", width: 26, height: 26),
    );
  }

  /// 全屏按钮
  Widget buildExpand(Function() onTap) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      onPressed: onTap,
      child: widget.isFullScreen
          ? Image.asset("images/full_screen_exit.png", width: 26, height: 26)
          : Image.asset("images/full_screen.png", width: 26, height: 26),
    );
  }

  /// 重播按钮
  Widget buildReplay(VoidCallback onTap) {
    return Container(
      color: Colors.black38,
      child: Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Image.asset("images/replay.png", width: 26, height: 26),
                ),
                Text(
                  "重新播放",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 屏幕中间的暂停按钮
  Widget buildCenterPause(VoidCallback onTap) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
            ),
            child: Image.asset("images/play.png", width: 26, height: 26),
          ),
        ),
      ),
    );
  }

  /// Wifi中断
  Widget buildWifiInterrupted(VoidCallback onTap) {
    return Container(
      color: Colors.black38,
      child: Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  "播放将消耗流量，确认继续播放",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF671F),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text(
                      "继续播放",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 发生错误
  Widget buildError(Function() onTap) {
    return Container(
      color: Colors.black38,
      child: Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  "无法连接网络，请检查网络设置后重试",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF671F),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text(
                      "点击重试",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 返回键
  Widget buildTopBar(Function() onTap) {
    if (widget.isFullScreen)
      return Align(
        alignment: Alignment.topLeft,
        child: CupertinoButton(
          onPressed: onTap,
          child: Container(
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    else
      return SizedBox();
  }
}
