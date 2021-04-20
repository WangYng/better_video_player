import 'package:better_video_player/src/controls/progress/better_video_player_progress_colors.dart';
import 'package:better_video_player/src/core/better_video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class BetterVideoPlayerProgressBar extends StatefulWidget {
  BetterVideoPlayerProgressBar({
    BetterVideoPlayerProgressColors? colors,
    required this.onDragEnd,
    required this.onDragStart,
    this.onDragUpdate,
    this.height = 3,
    Key? key,
  })  : colors = colors ?? BetterVideoPlayerProgressColors(),
        super(key: key);

  final BetterVideoPlayerProgressColors colors;
  final Function onDragStart;
  final Function onDragEnd;
  final Function? onDragUpdate;
  final double height;

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<BetterVideoPlayerProgressBar> {
  VoidCallback? listener;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BetterVideoPlayerController>();
    final videoPlayerValue = controller.value.videoPlayerController?.value;

    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      context.read<BetterVideoPlayerController>().onProgressDragUpdate(relative);
    }

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        context.read<BetterVideoPlayerController>().onProgressDragStart();

        widget.onDragStart();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.globalPosition);

        if (widget.onDragUpdate != null) {
          widget.onDragUpdate!();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        context.read<BetterVideoPlayerController>().onProgressDragEnd();

        widget.onDragEnd();
      },
      onTapDown: (TapDownDetails details) {
        seekToRelativePosition(details.globalPosition);
      },
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              videoPlayerValue,
              widget.colors,
              widget.height,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, this.colors, this.height);

  VideoPlayerValue? value;
  BetterVideoPlayerProgressColors colors;
  double height;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    if (!(value?.isInitialized ?? false)) {
      return;
    }
    final double playedPartPercent =
        (value?.position ?? Duration.zero).inMilliseconds / (value?.duration ?? Duration.zero).inMilliseconds;
    final double playedPart = playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (final DurationRange range in (value?.buffered ?? [])) {
      final double start = range.startFraction(value?.duration ?? Duration.zero) * size.width;
      final double end = range.endFraction(value?.duration ?? Duration.zero) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, size.height / 2),
            Offset(end, size.height / 2 + height),
          ),
          const Radius.circular(4.0),
        ),
        colors.bufferedPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );
    canvas.drawCircle(
      Offset(playedPart, size.height / 2 + height / 2),
      height * 2,
      colors.handlePaint,
    );

    canvas.drawCircle(
      Offset(playedPart, size.height / 2 + height / 2),
      height * 1.1,
      colors.playedPaint,
    );
  }
}
