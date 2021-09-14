import 'dart:async';

import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player/src/configuration/better_video_player_configuration.dart';
import 'package:better_video_player/src/core/better_video_player_utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BetterVideoPlayerController extends ValueNotifier<BetterVideoPlayerValue> {
  bool _wasPlayingBeforePause = false;

  // normal player controller
  BetterVideoPlayerController.configuration(BetterVideoPlayerConfiguration betterPlayerConfiguration)
      : super(BetterVideoPlayerValue(
          playerKey: UniqueKey(),
          isFullScreenMode: false,
          configuration: betterPlayerConfiguration,
          playerEventStreamController: StreamController.broadcast(),
        ));

  // full screen player controller
  BetterVideoPlayerController.copy(BetterVideoPlayerController betterVideoPlayerController)
      : super(betterVideoPlayerController.value.copyWith(isFullScreenMode: true));

  // listener wifi interrupt
  StreamSubscription? _connectivitySubscription;

  // emit player event
  Stream<BetterVideoPlayerEvent> get playerEventStream => value.playerEventStreamController.stream;

  Future<VoidCallback> attachVideoPlayerController(VideoPlayerController videoPlayerController) async {
    value = value.copyWith(videoPlayerController: videoPlayerController);

    videoPlayerController.addListener(_onVideoPlayerChanged);

    if (videoPlayerController.value.hasError) {
      bool hasError = value.hasError;
      value = value.copyWith(hasError: videoPlayerController.value.hasError);
      if (hasError == false && value.hasError == true) {
        value.playerEventStreamController.sink
            .add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onError));
      }
      return _onVideoPlayerChanged;
    }

    await start();
    return _onVideoPlayerChanged;
  }

  Future<void> start() async {
    // 开始自动播放
    if (value.configuration.autoPlay) {
      _wasPlayingBeforePause = true;
      if (value.visibilityFraction > 0) {
        play();
      }
    }

    await value.videoPlayerController?.setLooping(value.configuration.looping);

    // 监听网络连接
    _connectivitySubscription?.cancel();
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi) {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result != ConnectivityResult.wifi) {
          value = value.copyWith(wifiInterrupted: true);
          if (value.videoPlayerController?.value.isPlaying ?? false) {
            pause();
          }
        }
      });
    }
  }

  void _onVideoPlayerChanged() {
    if (_dispose) {
      return;
    }

    value = value.copyWith(
      isLoading: BetterVideoPlayerUtils.isLoading(value.videoPlayerController?.value),
    );

    if (value.videoPlayerController?.value.isPlaying ?? false) {
      value = value.copyWith(isPauseFromUser: false);
    }

    // emit playEnd event
    bool isVideoFinish = value.isVideoFinish;
    value = value.copyWith(isVideoFinish: BetterVideoPlayerUtils.isVideoFinished(value.videoPlayerController?.value));
    if (isVideoFinish == false && value.isVideoFinish == true) {
      value.playerEventStreamController.sink
          .add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onPlayEnd));
    }

    // emit onError event
    bool hasError = value.hasError;
    value = value.copyWith(hasError: value.videoPlayerController?.value.hasError ?? false);
    if (hasError == false && value.hasError == true) {
      value.playerEventStreamController.sink
          .add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onError));
    }
  }

  /// 进入全屏
  void enterFullScreen() {
    if (value.enterFullScreenCallback != null) {
      value.enterFullScreenCallback!();
      _wasPlayingBeforePause = false;
    }
  }

  /// 退出全屏
  void exitFullScreen() {
    if (value.exitFullScreenCallback != null) {
      value.exitFullScreenCallback!();
    }
  }

  /// 播放
  Future<void> play() async {
    if (value.videoPlayerController?.value.isInitialized == true) {
      if (value.videoPlayerController?.value.isPlaying ?? false) {
        return;
      }
      await value.videoPlayerController?.play();
      value.playerEventStreamController.sink
          .add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onPlay));

      if (value.wifiInterrupted) {
        value = value.copyWith(wifiInterrupted: false);
        _connectivitySubscription?.cancel();
      }
    }
  }

  /// 重启播放器
  Future<void> restart() async {
    if (value.videoPlayerController != null && value.videoPlayerController!.value.hasError) {
      value.playerEventStreamController.sink
          .add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onRestart));

      // remove error
      value.videoPlayerController!.value = VideoPlayerValue(
        duration: value.videoPlayerController!.value.duration,
        size: value.videoPlayerController!.value.size,
        position: value.videoPlayerController!.value.position,
        caption: value.videoPlayerController!.value.caption,
        buffered: value.videoPlayerController!.value.buffered,
        isPlaying: value.videoPlayerController!.value.isPlaying,
        isLooping: value.videoPlayerController!.value.isLooping,
        isBuffering: value.videoPlayerController!.value.isBuffering,
        volume: value.videoPlayerController!.value.volume,
        playbackSpeed: value.videoPlayerController!.value.playbackSpeed,
        errorDescription: null,
      );

      // auto play
      value = value.copyWith(configuration: value.configuration.copyWith(autoPlay: true));

      try {
        await value.videoPlayerController!.initialize();
      } catch (e) {
        value.videoPlayerController!.value =
            value.videoPlayerController!.value.copyWith(errorDescription: e.toString());
      }

      if (value.videoPlayerController!.value.hasError) {
        return;
      }

      start();
    }
  }

  /// 循环播放
  Future<void> setLooping(bool looping) async {
    await value.videoPlayerController?.setLooping(looping);
  }

  /// 暂停
  Future<void> pause() async {
    if (value.configuration.autoPlay) {
      // 可能还在初始化中, 需要关闭自动播放
      value = value.copyWith(configuration: value.configuration.copyWith(autoPlay: false));
    }

    if (value.videoPlayerController?.value.isInitialized == true) {
      await value.videoPlayerController?.pause();

      value.playerEventStreamController.sink
          .add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onPause));
    }
  }

  /// 跳转
  Future<void> seekTo(Duration moment) async {
    if (value.videoPlayerController?.value.isInitialized == true) {
      await value.videoPlayerController?.seekTo(moment);
    }
  }

  /// 音量
  Future<void> setVolume(double volume) async {
    if (value.videoPlayerController?.value.isInitialized == true) {
      await value.videoPlayerController?.setVolume(volume);

      value.playerEventStreamController.sink
          .add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onSetVolume));
    }
  }

  void onPlayerVisibilityChanged(double visibilityFraction) async {
    value = value.copyWith(visibilityFraction: visibilityFraction);

    if (value.videoPlayerController == null) {
      return;
    }

    if (value.videoPlayerController != null) {
      if (visibilityFraction == 0) {
        _wasPlayingBeforePause = value.videoPlayerController!.value.isPlaying;
        if (_wasPlayingBeforePause) {
          await pause();
        }
      } else {
        if (_wasPlayingBeforePause && value.configuration.autoPlayWhenResume) {
          await play();
        }

        _onVideoPlayerChanged();
      }
    }
  }

  void onProgressDragStart() async {
    _wasPlayingBeforePause = value.videoPlayerController?.value.isPlaying ?? false;
    if (_wasPlayingBeforePause) {
      await pause();
    }
  }

  void onProgressDragUpdate(double relative) async {
    if (value.videoPlayerController?.value.isInitialized == true) {
      final Duration position = (value.videoPlayerController?.value.duration ?? Duration.zero) * relative;
      await seekTo(position);
    }
  }

  void onProgressDragEnd() async {
    if (_wasPlayingBeforePause && value.videoPlayerController?.value.isInitialized == true) {
      // except seek to end.
      final duration = value.videoPlayerController?.value.duration ?? Duration.zero;
      final position = value.videoPlayerController?.value.position ?? Duration.zero;
      if (duration != Duration.zero && duration > position) {
        await play();
      }
    }
  }

  var _dispose = false;

  @override
  void dispose() {
    if (!_dispose) {
      _dispose = true;
      _connectivitySubscription?.cancel();

      if (value.isFullScreenMode == false) {
        value.playerEventStreamController.close();
      }
      super.dispose();
    }
  }
}

class BetterVideoPlayerValue {
  final Key playerKey;

  // 全屏模式
  final bool isFullScreenMode;

  // 事件处理
  final StreamController<BetterVideoPlayerEvent> playerEventStreamController;

  // 当前页面显示状态, 0 是隐藏, 1 是显示, 其它为中间状态
  final double visibilityFraction;

  // 当前是否为加载中
  final bool isLoading;

  // 播放完成
  final bool isVideoFinish;

  // 发生错误
  final bool hasError;

  // wifi中断
  final bool wifiInterrupted;

  // 当前播放器的配置
  final BetterVideoPlayerConfiguration configuration;

  // 当前使用的真实播放器
  VideoPlayerController? videoPlayerController;

  // 进入全屏的监听
  final VoidCallback? enterFullScreenCallback;

  // 退出全屏的监听
  final VoidCallback? exitFullScreenCallback;

  BetterVideoPlayerValue({
    required this.playerKey,
    required this.isFullScreenMode,
    required this.playerEventStreamController,
    this.visibilityFraction = 1,
    this.isLoading = true,
    this.isVideoFinish = false,
    this.hasError = false,
    this.wifiInterrupted = false,
    this.configuration = const BetterVideoPlayerConfiguration(),
    this.videoPlayerController,
    this.enterFullScreenCallback,
    this.exitFullScreenCallback,
  });

  BetterVideoPlayerValue copyWith({
    bool? isFullScreenMode,
    double? visibilityFraction,
    bool? isLoading,
    bool? isPauseFromUser,
    bool? isVideoFinish,
    bool? hasError,
    bool? wifiInterrupted,
    BetterVideoPlayerConfiguration? configuration,
    VideoPlayerController? videoPlayerController,
    VoidCallback? enterFullScreenCallback,
    VoidCallback? exitFullScreenCallback,
  }) {
    return BetterVideoPlayerValue(
      playerKey: this.playerKey,
      isFullScreenMode: isFullScreenMode ?? this.isFullScreenMode,
      playerEventStreamController: this.playerEventStreamController,
      visibilityFraction: visibilityFraction ?? this.visibilityFraction,
      isLoading: isLoading ?? this.isLoading,
      isVideoFinish: isVideoFinish ?? this.isVideoFinish,
      hasError: hasError ?? this.hasError,
      wifiInterrupted: wifiInterrupted ?? this.wifiInterrupted,
      configuration: configuration ?? this.configuration,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      enterFullScreenCallback: enterFullScreenCallback ?? this.enterFullScreenCallback,
      exitFullScreenCallback: exitFullScreenCallback ?? this.exitFullScreenCallback,
    );
  }
}
