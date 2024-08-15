import 'dart:async';
import 'dart:io';

import 'package:better_video_player/src/configuration/better_video_data_source.dart';
import 'package:better_video_player/src/configuration/better_video_data_source_type.dart';
import 'package:better_video_player/src/configuration/better_video_player_configuration.dart';
import 'package:better_video_player/src/core/better_video_player_with_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'better_video_player_controller.dart';

/// 播放器
class BetterVideoPlayer extends StatelessWidget {
  final BetterVideoPlayerController controller;

  final BetterVideoPlayerConfiguration configuration;

  final BetterVideoPlayerDataSource? dataSource;

  final bool isFullScreen;

  const BetterVideoPlayer({
    Key? key,
    required this.controller,
    required this.configuration,
    this.dataSource,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BetterVideoPlayerController>.value(
      value: controller,
      child: _BetterVideoPlayer(
        configuration: configuration,
        dataSource: dataSource,
        isFullScreen: isFullScreen,
      ),
    );
  }
}

class _BetterVideoPlayer extends StatefulWidget {
  final BetterVideoPlayerConfiguration configuration;

  /// 数据源, 如果有数据源, 使用数据源创建播放控制器
  final BetterVideoPlayerDataSource? dataSource;

  final bool isFullScreen;

  const _BetterVideoPlayer({Key? key, required this.configuration, this.dataSource, required this.isFullScreen})
      : super(key: key);

  @override
  BetterVideoPlayerState createState() {
    return BetterVideoPlayerState();
  }
}

class BetterVideoPlayerState extends State<_BetterVideoPlayer> with WidgetsBindingObserver {
  late BetterVideoPlayerController betterVideoPlayerController;

  bool _willPop = false;

  bool _fullScreen = false;

  @override
  void initState() {
    super.initState();

    betterVideoPlayerController = context.read<BetterVideoPlayerController>();

    Future.delayed(Duration.zero, () async {
      final controller = context.read<BetterVideoPlayerController>();

      // 绑定事件
      controller.value =
          controller.value.copyWith(exitFullScreenCallback: _onExitFullScreen, configuration: widget.configuration);

      VideoPlayerController? videoPlayerController;

      if (context.read<BetterVideoPlayerController>().value.videoPlayerController != null) {
        videoPlayerController = context.read<BetterVideoPlayerController>().value.videoPlayerController!;

        // 绑定播放控制器
        controller.attachVideoPlayerController(videoPlayerController: videoPlayerController);

        await controller.start();

      } else if (widget.dataSource != null) {
        // 初始化播放器
        switch (widget.dataSource!.type) {
          case BetterVideoPlayerDataSourceType.network:
            videoPlayerController = VideoPlayerController.network(widget.dataSource!.url);
            break;

          case BetterVideoPlayerDataSourceType.file:
            videoPlayerController = VideoPlayerController.file(File(widget.dataSource!.url));
            break;

          case BetterVideoPlayerDataSourceType.asset:
            videoPlayerController = VideoPlayerController.asset(widget.dataSource!.url);
            break;
        }

        try {
          // 创建后必须要初始化才能使用
          await videoPlayerController.initialize();
        } catch (e) {
          videoPlayerController.value = videoPlayerController.value.copyWith(errorDescription: e.toString());
        }

        // 绑定播放控制器
        controller.attachVideoPlayerController(videoPlayerController: videoPlayerController);
        await controller.start();
      }

      // 绑定事件
      controller.value = controller.value.copyWith(enterFullScreenCallback: _onEnterFullScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerKey = context.read<BetterVideoPlayerController>().value.playerKey;
    return VisibilityDetector(
      key: playerKey,
      onVisibilityChanged: (VisibilityInfo info) {
        // 这个框架在回调时有一个延迟, 目的是为了去重, 防止连续多次回调,
        // 相同的key如果连续多次触发, 只会返回最后一次
        // 如果不同的页面使用相同的Key, 同样也会去重
        // 当dispose后会回调
        if (!_willPop && !_fullScreen) {
          context.read<BetterVideoPlayerController>().onPlayerVisibilityChanged(info.visibleFraction);
        }
      },
      child: BetterVideoPlayerWithControls(
        isFullScreen: widget.isFullScreen,
        configuration: widget.configuration,
      ),
    );
  }

  @override
  void dispose() {
    if (!_willPop) {
      _willPop = true;
    }

    betterVideoPlayerController.detachVideoPlayerController();

    super.dispose();
  }

  void _onEnterFullScreen() async {

    bool allowedScreenSleep = widget.configuration.allowedScreenSleep;
    final aspectRatio = context.read<BetterVideoPlayerController>().videoPlayerValue?.aspectRatio ?? 1.0;

    // 进入全屏页面
    final pushResult = _pushFullScreenPage();

    // 全屏旋转
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

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
    SystemChrome.setPreferredOrientations(deviceOrientations);

    // 屏幕常亮
    bool closeWakelock = false;
    if (!allowedScreenSleep && !(await WakelockPlus.enabled)) {
      WakelockPlus.enable();
      closeWakelock = true;
    }

    _fullScreen = true;
    await pushResult;
    _fullScreen = false;

    // 关闭屏幕常亮
    if (closeWakelock) {
      WakelockPlus.disable();
    }

    // 恢复全屏旋转
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    if (aspectRatio < 1.0) {
    } else {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  Future _pushFullScreenPage() async {
    try {
      final controller = context.read<BetterVideoPlayerController>();

      // 关闭视频播放器监听
      controller.detachVideoPlayerController();

      final fullScreenController = BetterVideoPlayerController.copy(controller);

      var fullScreenConfiguration = widget.configuration;
      final isPlaying = fullScreenController.value.videoPlayerController!.value.isPlaying;
      fullScreenConfiguration = fullScreenConfiguration.copyWith(autoPlay: isPlaying);

      fullScreenController.value = fullScreenController.value.copyWith(configuration: fullScreenConfiguration);

      final result = Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute<BetterVideoPlayer>(builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: BetterVideoPlayer(
                configuration: fullScreenConfiguration,
                controller: fullScreenController,
                isFullScreen: true,
              ),
            ),
          );
        }),
      ).then((value) {

        // 需要延时, 因为页面关闭后不会立即释放provider
        Future.delayed(Duration(milliseconds: 500), () {
          fullScreenController.dispose();
        });

        if (_willPop == false) {
          // 恢复视频播放器监听
          context.read<BetterVideoPlayerController>().attachVideoPlayerController();
        }

        return value;
      });

      return result;
    } catch (e) {
      print("wang $e");
    }
  }

  void _onExitFullScreen() async {
    _willPop = true;
    Navigator.pop(context);
  }
}
