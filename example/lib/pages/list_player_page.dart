import 'dart:async';

import 'package:better_video_player/better_video_player.dart';
import 'package:better_video_player_example/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListPlayerPage extends StatefulWidget {
  @override
  _ListPlayerPageState createState() => _ListPlayerPageState();
}

class _ListPlayerPageState extends State<ListPlayerPage> {
  int _playingIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List player"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
              child: Text(
                "100 video player in ListView.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ItemWidget(
                  index: index,
                  playingIndex: _playingIndex,
                  onPlayButtonPressed: () {
                    setState(() {
                      _playingIndex = index;
                    });
                  },
                );
              },
              childCount: 100,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemWidget extends StatefulWidget {
  final int playingIndex;

  final int index;

  final VoidCallback onPlayButtonPressed;

  const ItemWidget({Key? key, required this.playingIndex, required this.index, required this.onPlayButtonPressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemWidgetState();
  }
}

class ItemWidgetState extends State<ItemWidget> with AutomaticKeepAliveClientMixin {
  BetterVideoPlayerController playerController = BetterVideoPlayerController();

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.playingIndex == oldWidget.index && widget.playingIndex != widget.index) {
      final oldPlayerController = playerController;
      Future.delayed(Duration(milliseconds: 500), () {
        oldPlayerController.dispose();
      });
      playerController = BetterVideoPlayerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.playingIndex != widget.index) Image.network(kTestVideoThumbnail, fit: BoxFit.contain),
            // play button
            if (widget.playingIndex != widget.index)
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    constraints: BoxConstraints.tightFor(width: 60, height: 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  onPressed: widget.onPlayButtonPressed,
                ),
              ),
            // video player
            if (widget.playingIndex == widget.index)
              BetterVideoPlayer(
                controller: playerController,
                dataSource: BetterVideoPlayerDataSource(
                  BetterVideoPlayerDataSourceType.network,
                  kTestVideoUrl,
                ),
                configuration: BetterVideoPlayerConfiguration(
                  placeholder: Image.network(kTestVideoThumbnail, fit: BoxFit.contain),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.playingIndex == widget.index;
}
