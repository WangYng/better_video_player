import 'package:video_player/video_player.dart';

class BetterVideoPlayerUtils {
  static String formatDuration(Duration position) {
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

    final formattedTime = '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

    return formattedTime;
  }

  static bool isVideoFinished(VideoPlayerValue? value) {
    if (value == null || value.duration <= Duration.zero) {
      return false;
    }

    return value.position >= value.duration;
  }

  ///Latest value can be null
  static bool isLoading(VideoPlayerValue? value) {
    if (value == null) {
      return true;
    }

    if (!value.isInitialized) {
      return true;
    }

    Duration? bufferedEndPosition;
    if (value.buffered.isNotEmpty == true) {
      bufferedEndPosition = value.buffered.last.end;
    }

    if (bufferedEndPosition != null) {
      if (value.isPlaying && value.isBuffering) {
        return true;
      }
    }
    return false;
  }

  static double? aspectRatio(VideoPlayerValue? value) {
    if (value == null || value.size.width == 0 || value.size.height == 0) {
      return null;
    }

    final double aspectRatio = value.size.width / value.size.height;

    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }
}
