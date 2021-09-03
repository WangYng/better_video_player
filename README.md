# better_video_player

Advanced video player based on video_player.

<img src="doc/example.gif" border="0" />

## Install Started

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  better_video_player: ^1.1.0
```

2. Install it

```bash
$ flutter packages get
```

## Normal usage

```dart
AspectRatio(
  aspectRatio: 16.0 / 9.0,
  child: BetterVideoPlayer(
    controller: BetterVideoPlayerController.configuration(
      BetterVideoPlayerConfiguration(
        placeholder: CachedNetworkImage(
          imageUrl: kVideoThumbnail,
          fit: BoxFit.cover,
        ),
      ),
    ),
    dataSource: BetterVideoPlayerDataSource(
      BetterVideoPlayerDataSourceType.network,
      kVideoUrl,
    ),
  ),
)
```

## Feature
- [x] placeholder
- [x] fullscreen
- [x] progress indicator
- [x] tip when wifi interrupted
- [x] auto play when resume
- [x] null safety
