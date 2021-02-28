#import "BetterVideoPlayerPlugin.h"
#if __has_include(<better_video_player/better_video_player-Swift.h>)
#import <better_video_player/better_video_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "better_video_player-Swift.h"
#endif

@implementation BetterVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBetterVideoPlayerPlugin registerWithRegistrar:registrar];
}
@end
