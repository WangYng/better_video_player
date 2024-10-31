import 'dart:async';
import 'dart:io';

import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player/src/configuration/better_video_player_configuration.dart';
import 'package:better_video_player/src/core/better_video_player_utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BetterVideoPlayerController extends ValueNotifier<BetterVideoPlayerValue> {
  // normal player controller
  BetterVideoPlayerController()
      : super(BetterVideoPlayerValue(
          playerKey: UniqueKey(),
          isFullScreenMode: false,
        ));

  // full screen player controller
  BetterVideoPlayerController.copy(BetterVideoPlayerController betterVideoPlayerController)
      : super(betterVideoPlayerController.value.copyWith(
          isFullScreenMode: true,
        ));

  // 创建视频播放器
  bool _isCreateVideoPlayerController = false;

  bool get isCreateVideoPlayerController => _isCreateVideoPlayerController;

  // 自动暂停
  bool _autoPause = false;

  // listener wifi interrupt
  StreamSubscription? _connectivitySubscription;

  // emit player event
  StreamController<BetterVideoPlayerEvent> _playerEventStreamController = StreamController.broadcast();

  Stream<BetterVideoPlayerEvent> get playerEventStream => _playerEventStreamController.stream;

  // video player
  VideoPlayerController? get videoPlayer => value.videoPlayerController;

  // video player value
  VideoPlayerValue? get videoPlayerValue => value.videoPlayerController?.value;

  @override
  set value(BetterVideoPlayerValue newValue) {
    if (_dispose) {
      return;
    }
    super.value = newValue;
  }

  /// 关联播放器
  void attachVideoPlayerController({VideoPlayerController? videoPlayerController}) {
    if (_dispose) {
      return;
    }
    value = value.copyWith(videoPlayerController: videoPlayerController);
    value.videoPlayerController?.addListener(_onVideoPlayerChanged);
  }

  /// 解除播放器关联
  void detachVideoPlayerController() {
    if (_dispose) {
      return;
    }
    value.videoPlayerController?.removeListener(_onVideoPlayerChanged);
  }

  /// 创建播放器
  Future<void> createVideoPlayerController({required BetterVideoPlayerDataSource dataSource}) async {
    late VideoPlayerController videoPlayerController;
    switch (dataSource.type) {
      case BetterVideoPlayerDataSourceType.network:
        videoPlayerController = VideoPlayerController.network(dataSource.url);
        break;

      case BetterVideoPlayerDataSourceType.file:
        videoPlayerController = VideoPlayerController.file(File(dataSource.url));
        break;

      case BetterVideoPlayerDataSourceType.asset:
        videoPlayerController = VideoPlayerController.asset(dataSource.url);
        break;
    }

    try {
      // 创建后必须要初始化才能使用
      await videoPlayerController.initialize();
    } catch (e) {
      print(e);
      videoPlayerController.value = videoPlayerController.value.copyWith(errorDescription: e.toString());
    }

    // 绑定播放控制器
    attachVideoPlayerController(videoPlayerController: videoPlayerController);

    _isCreateVideoPlayerController = true;
  }

  /// 销毁播放器
  void destroyVideoPlayerController() {
    detachVideoPlayerController();

    if (_isCreateVideoPlayerController) {
      value.videoPlayerController?.dispose();
    }

    if (_dispose) {
      return;
    }

    // 更新数据
    value = value.removeVideoPlayerController();
  }

  /// 开始播放
  Future<void> start() async {
    if (_dispose) {
      return;
    }

    // 检查错误
    if (videoPlayerValue?.hasError == true) {
      return;
    }

    // 开始自动播放
    if (value.configuration.autoPlay && value.visibilityFraction > 0) {
      play();
    }

    // 设置播放循环
    await value.videoPlayerController?.setLooping(value.configuration.looping);

    // 监听网络连接，如果 wifi 断开，提醒用户
    _connectivitySubscription?.cancel();
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi) {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (value.videoPlayerController?.hasListeners == true) {
          if (result != ConnectivityResult.wifi) {
            value = value.copyWith(wifiInterrupted: true);
            if (videoPlayerValue?.isPlaying ?? false) {
              pause();
            }
          }
        }
      });
    }
  }

  // 播放器状态变化
  void _onVideoPlayerChanged() async {
    if (_dispose) {
      return;
    }

    await Future.delayed(Duration.zero);

    value = value.copyWith(isLoading: BetterVideoPlayerUtils.isLoading(videoPlayerValue));

    // emit playEnd event
    bool isVideoFinish = value.isVideoFinish;
    value = value.copyWith(isVideoFinish: BetterVideoPlayerUtils.isVideoFinished(videoPlayerValue));
    if (isVideoFinish == false && value.isVideoFinish == true) {
      _playerEventStreamController.sink.add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onPlayEnd));
    }
  }

  /// 进入全屏
  void enterFullScreen() {
    if (_dispose) {
      return;
    }

    if (value.enterFullScreenCallback != null) {
      value.enterFullScreenCallback!();
      _autoPause = false;
    }
  }

  /// 退出全屏
  void exitFullScreen() {
    if (_dispose) {
      return;
    }

    if (value.exitFullScreenCallback != null) {
      value.exitFullScreenCallback!();
    }
  }

  /// 播放
  Future<void> play() async {
    if (_dispose) {
      return;
    }

    if (videoPlayerValue?.isInitialized == true) {
      if (videoPlayerValue?.isPlaying ?? false) {
        return;
      }

      // 开始播放
      await value.videoPlayerController?.play();

      if (_dispose) {
        return;
      }

      // 发送开始播放事件
      _playerEventStreamController.sink.add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onPlay));

      if (value.wifiInterrupted) {
        // 去掉 Wifi 中断提醒
        value = value.copyWith(wifiInterrupted: false);
        _connectivitySubscription?.cancel();
      }
    }
  }

  /// 发生错误, 重新播放
  Future<void> restart() async {
    if (_dispose) {
      return;
    }

    if (value.videoPlayerController != null && value.videoPlayerController!.value.hasError) {
      _playerEventStreamController.sink.add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onRestart));

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
        value.videoPlayerController!.value = value.videoPlayerController!.value.copyWith(errorDescription: e.toString());
      }

      if (value.videoPlayerController!.value.hasError) {
        return;
      }

      start();
    }
  }

  /// 循环播放
  Future<void> setLooping(bool looping) async {
    if (_dispose) {
      return;
    }

    await value.videoPlayerController?.setLooping(looping);
  }

  /// 暂停
  Future<void> pause() async {
    if (_dispose) {
      return;
    }

    if (videoPlayerValue?.isInitialized == true) {
      // 暂停播放
      await value.videoPlayerController?.pause();

      _playerEventStreamController.sink.add(BetterVideoPlayerEvent(value.playerKey, BetterVideoPlayerEventType.onPause));
    } else {
      // 如果在初始化中, 需要关闭自动播放
      value = value.copyWith(configuration: value.configuration.copyWith(autoPlay: false));
    }
  }

  /// 跳转
  Future<void> seekTo(Duration moment) async {
    if (_dispose) {
      return;
    }

    if (videoPlayerValue?.isInitialized == true) {
      await value.videoPlayerController?.seekTo(moment);
    }
  }

  /// 音量
  Future<void> setVolume(double volume) async {
    if (_dispose) {
      return;
    }

    if (videoPlayerValue?.isInitialized == true) {
      await value.videoPlayerController?.setVolume(volume);
    }
  }

  /// 播放器被遮挡
  void onPlayerVisibilityChanged(double visibilityFraction) async {
    if (_dispose) {
      return;
    }

    // 不监听播放器变化
    if ((value.videoPlayerController?.hasListeners ?? false) == false) {
      return;
    }

    value = value.copyWith(visibilityFraction: visibilityFraction);

    final videoPlayerController = value.videoPlayerController;
    if (videoPlayerController == null) {
      return;
    }

    if (visibilityFraction == 0) {
      _autoPause = videoPlayerController.value.isPlaying;
      if (_autoPause) {
        await pause();
      }
    } else {
      if (_autoPause && value.configuration.autoPlayWhenResume) {
        _autoPause = false;
        await play();
      }

      _onVideoPlayerChanged();
    }
  }

  void onProgressDragStart() async {
    if (_dispose) {
      return;
    }

    _autoPause = videoPlayerValue?.isPlaying ?? false;
    if (_autoPause) {
      await pause();
    }
  }

  void onProgressDragUpdate(double relative) async {
    if (_dispose) {
      return;
    }

    if (videoPlayerValue?.isInitialized == true) {
      final Duration position = (videoPlayerValue?.duration ?? Duration.zero) * relative;
      await seekTo(position);
    }
  }

  void onProgressDragEnd() async {
    if (_dispose) {
      return;
    }

    if (_autoPause && videoPlayerValue?.isInitialized == true) {
      _autoPause = false;
      // except seek to end.
      final duration = videoPlayerValue?.duration ?? Duration.zero;
      final position = videoPlayerValue?.position ?? Duration.zero;
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

      value.videoPlayerController?.removeListener(_onVideoPlayerChanged);

      _connectivitySubscription?.cancel();

      _playerEventStreamController.close();

      super.dispose();
    }
  }
}

class BetterVideoPlayerValue {
  // 用来区分播放器事件
  final Key playerKey;

  // 全屏模式
  final bool isFullScreenMode;

  // 当前页面显示状态, 0 是隐藏, 1 是显示, 其它为中间状态
  final double visibilityFraction;

  // 当前是否为加载中
  final bool isLoading;

  // 播放完成
  final bool isVideoFinish;

  // wifi中断
  final bool wifiInterrupted;

  // 当前播放器的配置
  final BetterVideoPlayerConfiguration configuration;

  // 当前播放器的数据源
  final BetterVideoPlayerDataSource? dataSource;

  // 当前使用的真实播放器
  final VideoPlayerController? videoPlayerController;

  // 进入全屏的监听
  final VoidCallback? enterFullScreenCallback;

  // 退出全屏的监听
  final VoidCallback? exitFullScreenCallback;

  BetterVideoPlayerValue({
    required this.playerKey,
    required this.isFullScreenMode,
    this.visibilityFraction = 1,
    this.isLoading = true,
    this.isVideoFinish = false,
    this.wifiInterrupted = false,
    this.configuration = const BetterVideoPlayerConfiguration(),
    this.dataSource,
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
    bool? wifiInterrupted,
    BetterVideoPlayerConfiguration? configuration,
    BetterVideoPlayerDataSource? dataSource,
    VideoPlayerController? videoPlayerController,
    VoidCallback? enterFullScreenCallback,
    VoidCallback? exitFullScreenCallback,
  }) {
    return BetterVideoPlayerValue(
      playerKey: this.playerKey,
      isFullScreenMode: isFullScreenMode ?? this.isFullScreenMode,
      visibilityFraction: visibilityFraction ?? this.visibilityFraction,
      isLoading: isLoading ?? this.isLoading,
      isVideoFinish: isVideoFinish ?? this.isVideoFinish,
      wifiInterrupted: wifiInterrupted ?? this.wifiInterrupted,
      configuration: configuration ?? this.configuration,
      dataSource: dataSource ?? this.dataSource,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      enterFullScreenCallback: enterFullScreenCallback ?? this.enterFullScreenCallback,
      exitFullScreenCallback: exitFullScreenCallback ?? this.exitFullScreenCallback,
    );
  }

  BetterVideoPlayerValue removeVideoPlayerController() {
    return BetterVideoPlayerValue(
      playerKey: this.playerKey,
      isFullScreenMode: this.isFullScreenMode,
      visibilityFraction: this.visibilityFraction,
      isLoading: this.isLoading,
      isVideoFinish: this.isVideoFinish,
      wifiInterrupted: this.wifiInterrupted,
      configuration: this.configuration,
      dataSource: this.dataSource,
      videoPlayerController: null,
      enterFullScreenCallback: this.enterFullScreenCallback,
      exitFullScreenCallback: this.exitFullScreenCallback,
    );
  }
}
