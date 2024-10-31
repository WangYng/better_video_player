import 'package:flutter/widgets.dart';

/// 播放器事件
enum BetterVideoPlayerEventType {
  onPlay,
  onPause,
  onPlayEnd,
  onRestart,
}

class BetterVideoPlayerEvent {
  final Key playerKey;
  final BetterVideoPlayerEventType type;

  BetterVideoPlayerEvent(this.playerKey, this.type);

  @override
  String toString() {
    return 'BetterVideoPlayerEvent{playerKey: $playerKey, type: $type}';
  }
}
