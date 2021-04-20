import 'package:better_video_player/src/controls/better_video_player_controls.dart';
import 'package:flutter/material.dart';

class BetterVideoPlayerConfiguration {
  /// 自动播放
  final bool autoPlay;

  /// 循环播放
  final bool looping;

  /// 视频启动前占位布局
  final Widget placeholder;

  /// 屏幕休眠
  final bool allowedScreenSleep;

  /// 返回自动恢复播放
  final bool autoPlayWhenResume;

  /// 播放控制器
  final Widget controls;

  /// 全屏播放控件器
  final Widget fullScreenControls;

  const BetterVideoPlayerConfiguration({
    this.autoPlay = true,
    this.looping = false,
    this.placeholder = const SizedBox(),
    this.allowedScreenSleep = false,
    this.autoPlayWhenResume = true,
    this.controls = const BetterVideoPlayerControls(isFullScreen: false),
    this.fullScreenControls =
        const BetterVideoPlayerControls(isFullScreen: true),
  });

  BetterVideoPlayerConfiguration copyWith({
    bool? autoPlay,
    bool? looping,
    Widget? placeholder,
    bool? allowedScreenSleep,
    bool? autoPlayWhenResume,
    Widget? controls,
    Widget? fullScreenControls,
  }) {
    return BetterVideoPlayerConfiguration(
      autoPlay: autoPlay ?? this.autoPlay,
      looping: looping ?? this.looping,
      placeholder: placeholder ?? this.placeholder,
      allowedScreenSleep: allowedScreenSleep ?? this.allowedScreenSleep,
      autoPlayWhenResume: autoPlayWhenResume ?? this.autoPlayWhenResume,
      controls: controls ?? this.controls,
      fullScreenControls: fullScreenControls ?? this.fullScreenControls,
    );
  }
}
