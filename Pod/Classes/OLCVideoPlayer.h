//
//  OLCPlayer.h
//  CustomVideoPlayer
//
//  Created by Lakitha Samarasinghe on 6/9/15.
//  Copyright (c) 2015 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const OLCPlayerVideoURL;
UIKIT_EXTERN NSString *const OLCPlayerPlayTime;

@protocol OLCVideoPlayerDelegate <NSObject>

@optional
- (void) onPlayInfoUpdate:(double) current withDuration:(double) duration;
- (void) onVideoTrackChanged:(NSUInteger) index;
- (void) onPlay:(NSUInteger) index;
- (void) onPause:(NSUInteger) index;
- (void) onFinishPlaying:(NSUInteger) index;

@end

@interface OLCVideoPlayer : UIControl

@property (nonatomic, weak) id <OLCVideoPlayerDelegate> delegate;
@property (nonatomic) CGRect frame;
@property (nonatomic) BOOL isPlaying;

- (void) playVideos:(NSArray *) videos;
- (void) playVideAtIndex:(NSUInteger) index;
- (void) play;
- (void) pause;
- (void) playNext;
- (void) playPrevious;
- (void) setVolume:(float) level;
- (float) getVolume;
- (void) loopVideo:(BOOL) loop;
- (void) shuffleVideos:(BOOL) shuffle;
- (void) seekToTime:(double) time;
- (void) setVideoGravity:(NSString*) gravity;
- (void) shutdown;
- (void) playInBackground;
- (void) playInForeground;
- (NSUInteger) getPlayIndex;
- (void) continusPlay:(BOOL) canplay;
- (double) getCurrentTime;

@end
