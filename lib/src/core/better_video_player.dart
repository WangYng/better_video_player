import 'dart:async';
import 'dart:io';

import 'package:better_video_player/src/configuration/better_video_data_source.dart';
import 'package:better_video_player/src/configuration/better_video_data_source_type.dart';
import 'package:better_video_player/src/core/better_video_player_with_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

import 'better_video_player_controller.dart';

/// 播放器
class BetterVideoPlayer extends StatelessWidget {
  final BetterVideoPlayerController controller;

  final BetterVideoPlayerDataSource? dataSource;

  final bool isFullScreen;

  const BetterVideoPlayer({
    Key? key,
    required this.controller,
    this.dataSource,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BetterVideoPlayerController>(
      create: (_) => controller,
      child: _BetterVideoPlayer(
        dataSource: dataSource,
        isFullScreen: isFullScreen,
      ),
    );
  }
}

class _BetterVideoPlayer extends StatefulWidget {
  /// 数据源, 如果有数据源, 使用数据源创建播放控制器
  final BetterVideoPlayerDataSource? dataSource;

  final bool isFullScreen;

  const _BetterVideoPlayer({Key? key, this.dataSource, required this.isFullScreen}) : super(key: key);

  @override
  BetterVideoPlayerState createState() {
    return BetterVideoPlayerState();
  }
}

class BetterVideoPlayerState extends State<_BetterVideoPlayer> with WidgetsBindingObserver {
  BetterVideoPlayerController? betterVideoPlayerController;
  VideoPlayerController? videoPlayerController;

  bool _willPop = false;

  @override
  void initState() {
    super.initState();

    betterVideoPlayerController = context.read<BetterVideoPlayerController>();

    Future.delayed(Duration.zero, () async {
      // 绑定事件
      context.read<BetterVideoPlayerController>().value =
          context.read<BetterVideoPlayerController>().value.copyWith(exitFullScreenCallback: _onExitFullScreen);

      if (widget.dataSource != null) {
        // 初始化播放器
        switch (widget.dataSource!.type) {
          case BetterVideoPlayerDataSourceType.network:
            videoPlayerController = VideoPlayerController.network(widget.dataSource!.url);
            break;

          case BetterVideoPlayerDataSourceType.file:
            videoPlayerController = VideoPlayerController.file(File(widget.dataSource!.url));
            break;
        }

        try {
          // 创建后必须要初始化才能使用
          await videoPlayerController!.initialize();
        } catch (e) {
          videoPlayerController!.value = videoPlayerController!.value.copyWith(errorDescription: e.toString());
        }

        // 绑定播放控制器
        context.read<BetterVideoPlayerController>().attachVideoPlayerController(videoPlayerController!);
      } else {
        VideoPlayerController videoPlayerController =
            context.read<BetterVideoPlayerController>().value.videoPlayerController!;

        // 绑定播放控制器
        context.read<BetterVideoPlayerController>().attachVideoPlayerController(videoPlayerController);
      }

      // 绑定事件
      context.read<BetterVideoPlayerController>().value =
          context.read<BetterVideoPlayerController>().value.copyWith(enterFullScreenCallback: _onEnterFullScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    String? url = widget.dataSource?.url;
    url = url ?? context.read<BetterVideoPlayerController>().value.videoPlayerController!.dataSource;
    return WillPopScope(
      onWillPop: () {
        _willPop = true;
        betterVideoPlayerController?.detachVideoPlayerController();
        return Future.value(true);
      },
      child: VisibilityDetector(
        key: Key(url),
        onVisibilityChanged: (VisibilityInfo info) {
          // 这个框架在回调时有一个延迟, 目的是为了去重, 防止连续多次回调,
          // 相同的key如果连续多次触发, 只会返回最后一次
          // 如果不同的页面使用相同的Key, 同样也会去重
          // 当dispose后会回调
          if (!_willPop) {
            context.read<BetterVideoPlayerController>().onPlayerVisibilityChanged(info.visibleFraction);
          }
        },
        child: BetterVideoPlayerWithControls(
          isFullScreen: widget.isFullScreen,
        ),
      ),
    );
  }



  @override
  void dispose() {
    if (!_willPop) {
      betterVideoPlayerController?.detachVideoPlayerController();
      _willPop = true;
    }
    videoPlayerController?.dispose();
    videoPlayerController = null;
    super.dispose();
  }

  void _onEnterFullScreen() async {
    await SystemChrome.setEnabledSystemUIOverlays([]);

    final aspectRatio =
        context.read<BetterVideoPlayerController>().value.videoPlayerController?.value.aspectRatio ?? 1.0;
    List<DeviceOrientation> deviceOrientations;
    if (aspectRatio < 1.0) {
      deviceOrientations = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
    } else {
      if (Platform.isIOS) {
        deviceOrientations = [DeviceOrientation.landscapeRight];
      } else if (Platform.isAndroid) {
        deviceOrientations = [
          DeviceOrientation.landscapeLeft,
        ];
      } else {
        deviceOrientations = [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
      }
    }
    await SystemChrome.setPreferredOrientations(deviceOrientations);

    final controller = context.read<BetterVideoPlayerController>();

    // 屏幕常亮
    bool closeWakelock = false;
    if (!controller.value.configuration.allowedScreenSleep && !(await Wakelock.enabled)) {
      await Wakelock.enable();
      closeWakelock = true;
    }

    final fullScreenController = BetterVideoPlayerController.copy(controller);
    var fullScreenConfiguration = fullScreenController.value.configuration;
    final isPlaying = fullScreenController.value.videoPlayerController!.value.isPlaying;

    fullScreenConfiguration = fullScreenConfiguration.copyWith(autoPlay: isPlaying);
    fullScreenController.value = fullScreenController.value.copyWith(configuration: fullScreenConfiguration);

    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute<BetterVideoPlayer>(builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: BetterVideoPlayer(
              controller: fullScreenController,
              isFullScreen: true,
            ),
          ),
        );
      }),
    );

    // 需要延时, 因为页面关闭后不会立即释放provider
    Future.delayed(Duration(milliseconds: 500), () => fullScreenController.dispose());

    if (closeWakelock) {
      await Wakelock.disable();
    }

    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    if (aspectRatio < 1.0) {
    } else {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _onExitFullScreen() async {
    _willPop = true;
    betterVideoPlayerController?.detachVideoPlayerController();
    Navigator.pop(context);
  }
}
