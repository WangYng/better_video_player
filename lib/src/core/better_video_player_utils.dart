import 'package:video_player/video_player.dart';

class BetterVideoPlayerUtils {
  static const int _bufferingInterval = 20000;

  static String formatDuration(Duration position) {
    assert(position != null, "Position can't be null!");
    final ms = position.inMilliseconds;

    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    final minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursString = hours >= 10
        ? '$hours'
        : hours == 0
            ? '00'
            : '0$hours';

    final minutesString = minutes >= 10
        ? '$minutes'
        : minutes == 0
            ? '00'
            : '0$minutes';

    final secondsString = seconds >= 10
        ? '$seconds'
        : seconds == 0
            ? '00'
            : '0$seconds';

    final formattedTime =
        '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

    return formattedTime;
  }

  static bool isVideoFinished(VideoPlayerValue value) {
    return value?.position != null &&
        value?.duration != null &&
        value.position >= value.duration;
  }

  ///Latest value can be null
  static bool isLoading(VideoPlayerValue value) {
    if (value == null || (!value.isPlaying && value.duration == null)) {
      return true;
    }

    final Duration position = value.position;

    Duration bufferedEndPosition;
    if (value.buffered?.isNotEmpty == true) {
      bufferedEndPosition = value.buffered.last.end;
    }

    if (position != null && bufferedEndPosition != null) {
      final difference = bufferedEndPosition - position;

      if (value.isPlaying &&
          value.isBuffering &&
          difference.inMilliseconds < _bufferingInterval) {
        return true;
      }
    }
    return false;
  }

  static double aspectRatio(VideoPlayerValue value) {
    if (value == null ||
        value.size == null ||
        value.size.width == 0 ||
        value.size.height == 0) {
      return null;
    }
    final double aspectRatio = value.size.width / value.size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }
}
