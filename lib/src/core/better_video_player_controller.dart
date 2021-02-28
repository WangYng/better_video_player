import 'dart:async';

import 'package:better_video_player/src/configuration/better_video_player_configuration.dart';
import 'package:better_video_player/src/core/better_video_player_utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BetterVideoPlayerController
    extends ValueNotifier<BetterVideoPlayerValue> {
  bool _wasPlayingBeforePause = false;

  BetterVideoPlayerController.configuration(
      BetterVideoPlayerConfiguration betterPlayerConfiguration)
      : super(BetterVideoPlayerValue(configuration: betterPlayerConfiguration));

  BetterVideoPlayerController.copy(
      BetterVideoPlayerController BetterVideoPlayerController)
      : super(BetterVideoPlayerController.value.copyWith());

  void attachVideoPlayerController(
      VideoPlayerController videoPlayerController) async {
    value = value.copyWith(videoPlayerController: videoPlayerController);

    videoPlayerController.addListener(_onVideoPlayerChanged);
    await videoPlayerController.setLooping(value.configuration.looping);

    // 开始自动播放
    if (value.configuration.autoPlay) {
      _wasPlayingBeforePause = true;
      if (value.visibilityFraction > 0) {
        play();
      }
    }
  }

  void _onVideoPlayerChanged() async {
    if (value.visibilityFraction == 0) {
      // 不在后台更新
      return;
    }

    value = value.copyWith(
      isLoading:
          BetterVideoPlayerUtils.isLoading(value.videoPlayerController.value),
    );

    value = value.copyWith(
      isVideoFinish: BetterVideoPlayerUtils.isVideoFinished(
          value.videoPlayerController.value),
    );
  }

  void setEnterFullScreenListener() {}

  /// 进入全屏
  void enterFullScreen() {
    if (value.enterFullScreenCallback != null) {
      value.enterFullScreenCallback();
    }
  }

  /// 退出全屏
  void exitFullScreen() {
    if (value.exitFullScreenCallback != null) {
      value.exitFullScreenCallback();
    }
  }

  /// 播放
  Future<void> play() async {
    await value.videoPlayerController?.play();
  }

  /// 循环播放
  Future<void> setLooping(bool looping) async {
    await value.videoPlayerController?.setLooping(looping);
  }

  /// 暂停
  Future<void> pause() async {
    await value.videoPlayerController?.pause();
  }

  /// 跳转
  Future<void> seekTo(Duration moment) async {
    await value.videoPlayerController?.seekTo(moment);
  }

  /// 音量
  Future<void> setVolume(double volume) async {
    await value.videoPlayerController?.setVolume(volume);
  }

  void onPlayerVisibilityChanged(double visibilityFraction) async {
    value = value.copyWith(visibilityFraction: visibilityFraction);

    if (value.videoPlayerController != null) {
      if (visibilityFraction == 0) {
        _wasPlayingBeforePause = value.videoPlayerController.value.isPlaying;
        await pause();
      } else {
        if (_wasPlayingBeforePause) {
          await play();
        }

        _onVideoPlayerChanged();
      }
    }
  }

  var _dispose = false;
  @override
  void dispose() {
    if (!_dispose) {
      _dispose = true;
      value.videoPlayerController?.removeListener(_onVideoPlayerChanged);
      super.dispose();
    }
  }
}

class BetterVideoPlayerValue {
  // 当前页面显示状态, 0 是隐藏, 1 是显示, 其它为中间状态
  final double visibilityFraction;

  // 当前是否为加载中
  final bool isLoading;

  // 播放完成
  final bool isVideoFinish;

  // 当前播放器的配置
  final BetterVideoPlayerConfiguration configuration;

  // 当前使用的真实播放器
  final VideoPlayerController videoPlayerController;

  // 进入全屏的监听
  final VoidCallback enterFullScreenCallback;

  // 退出全屏的监听
  final VoidCallback exitFullScreenCallback;

  BetterVideoPlayerValue({
    this.visibilityFraction = 1,
    this.isLoading = true,
    this.isVideoFinish = false,
    this.configuration = const BetterVideoPlayerConfiguration(),
    this.videoPlayerController,
    this.enterFullScreenCallback,
    this.exitFullScreenCallback,
  });

  BetterVideoPlayerValue copyWith({
    double visibilityFraction,
    bool isLoading,
    bool isVideoFinish,
    BetterVideoPlayerConfiguration configuration,
    VideoPlayerController videoPlayerController,
    VoidCallback enterFullScreenCallback,
    VoidCallback exitFullScreenCallback,
  }) {
    return BetterVideoPlayerValue(
      visibilityFraction: visibilityFraction ?? this.visibilityFraction,
      isLoading: isLoading ?? this.isLoading,
      isVideoFinish: isVideoFinish ?? this.isVideoFinish,
      configuration: configuration ?? this.configuration,
      videoPlayerController:
          videoPlayerController ?? this.videoPlayerController,
      enterFullScreenCallback:
          enterFullScreenCallback ?? this.enterFullScreenCallback,
      exitFullScreenCallback:
          exitFullScreenCallback ?? this.exitFullScreenCallback,
    );
  }
}
