//
//  OLCPlayer.m
//  CustomVideoPlayer
//
//  Created by Lakitha Samarasinghe on 6/9/15.
//  Copyright (c) 2015 Fidenz. All rights reserved.
//

#import "OLCVideoPlayer.h"

#define OLC_UPDATETIMER_INTERVAL 0.2

NSString *const OLCPlayerVideoURL = @"OLCPlayerVideoURL";
NSString *const OLCPlayerPlayTime = @"OLCPlayerPlayTime";

@implementation OLCVideoPlayer
{
    AVPlayerLayer *playerCtrl;
    NSArray *videolist;
    NSUInteger playIndex;
    BOOL doLoop;
    BOOL doShuffle;
    float volumeLevel;
    CGRect playframe;
    BOOL canPlayContinus;
    BOOL playerInit;
    NSTimer *playstatustimer;
    
    //current item related stuff
    double playtime;
    double currentplaytime;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        playframe = frame;
        [self initPlayer];
    }
    
    return self;
}

- (void) willMoveToWindow:(UIWindow *)newWindow
{
    playframe = newWindow.frame;
    
    if(!playerInit)
    {
        [self initPlayer];
    }
}

#pragma mark - public

- (void) playVideos:(NSArray *) videos
{
    videolist = videos;
    
    if([videolist count] > 0)
    {
        [self playVideAtIndex:0];
    }
}

- (void) play
{
    self.isPlaying = YES;
    [playerCtrl.player play];
    
    if ([self.delegate respondsToSelector:@selector(onPlay:)])
    {
        [[self delegate] onPlay:playIndex];
    }
}

- (void) pause
{
    self.isPlaying = NO;
    [playerCtrl.player pause];
    
    if ([self.delegate respondsToSelector:@selector(onPause:)])
    {
        [[self delegate] onPause:playIndex];
    }
}

- (void) playNext
{
    currentplaytime = 0;
    
    if(doShuffle)
    {
        int randNum = rand() % (([videolist count]) - 0) + 0;
        [self playVideAtIndex:randNum];
    }
    else
    {
        if(playIndex < [videolist count]-1)
        {
            playIndex+=1;
            [self playVideAtIndex:playIndex];
        }
        else
        {
            playIndex = 0;
            [self playVideAtIndex:playIndex];
        }
    }
}

- (void) playPrevious
{
    if(doShuffle)
    {
        int randNum = rand() % (([videolist count] -1) - 0) + 0;
        [self playVideAtIndex:randNum];
    }
    else
    {
        if(playIndex == 0)
        {
            playIndex = [videolist count] - 1;
            [self playVideAtIndex:playIndex];
        }
        else
        {
            playIndex -=1;
            [self playVideAtIndex:playIndex];
        }
    }
}

- (void) playVideAtIndex:(NSUInteger) index
{
    playIndex = index;
    
    [self playVideo:index];
}

- (void) setVolume:(float) level
{
    volumeLevel = level;
    [playerCtrl.player setVolume:level];
}

- (float) getVolume
{
    return volumeLevel;
}

- (void) loopVideo:(BOOL) loop
{
    doLoop = loop;
}

- (void) shuffleVideos:(BOOL) shuffle
{
    doShuffle = shuffle;
}

- (void) setVideoGravity:(NSString*) gravity
{
    playerCtrl.videoGravity = gravity;
}

- (void) shutdown
{
    [self unregisterNotifcations];
    [playerCtrl.player pause];
    playerCtrl.player = nil;
    [playstatustimer invalidate];
    playstatustimer = nil;
    playerCtrl = nil;
    videolist  = nil;
    
    for (UIView *view in self.superview.subviews) {
        [view removeFromSuperview];
    }
    
    [self removeFromSuperview];
}

- (void) playInBackground
{
    AVPlayerItem *playerItem = [playerCtrl.player currentItem];
    
    NSArray *tracks = [playerItem tracks];
    for (AVPlayerItemTrack *playerItemTrack in tracks)
    {
        // find video tracks
        if ([playerItemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual])
        {
            playerItemTrack.enabled = NO; // disable the track
        }
    }

}

- (void) playInForeground
{
    AVPlayerItem *playerItem = [playerCtrl.player currentItem];
    
    NSArray *tracks = [playerItem tracks];
    for (AVPlayerItemTrack *playerItemTrack in tracks)
    {
        // find video tracks
        if ([playerItemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual])
        {
            playerItemTrack.enabled = YES; // disable the track
        }
    }
}

- (NSUInteger) getPlayIndex
{
    return playIndex;
}

- (void) continusPlay:(BOOL) canplay
{
    canPlayContinus = canplay;
}

- (double) getCurrentTime
{
    AVPlayerItem *currentItem = playerCtrl.player.currentItem;
    double startTime = 0;
    
    if(currentItem)
    {
        startTime = CMTimeGetSeconds(currentItem.currentTime);
    }
    
    return startTime;
}

#pragma mark - private

- (void) registerNotifcations
{
    playerCtrl.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[playerCtrl.player currentItem]];
    
    playerCtrl.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
}

- (void) unregisterNotifcations
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void) initPlayer
{
    playerInit = YES;
    canPlayContinus = YES;
    doLoop = NO;
    playIndex = 0;
    volumeLevel = 1.0f;
    
    self.isPlaying = NO;
    
    // Load the video asset
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:nil options:nil];
    
    // Create a player item
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    // Create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
    
    playerCtrl = [AVPlayerLayer playerLayerWithPlayer:player];
    playerCtrl.player = player;
    playerCtrl.frame  = playframe;
    playerCtrl.player.allowsExternalPlayback = NO; //this allow airplay for some reason
    playerCtrl.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    playerCtrl.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.layer addSublayer:playerCtrl];
    
    [self registerNotifcations];
    
    playstatustimer = [NSTimer scheduledTimerWithTimeInterval:OLC_UPDATETIMER_INTERVAL
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) playVideo:(NSUInteger) index
{
    NSDictionary *video  = [videolist objectAtIndex:index];
    
    playtime        = [[video valueForKey:OLCPlayerPlayTime] doubleValue];
    
    NSURL    *fileURL    = [video valueForKey:OLCPlayerVideoURL];
    NSNumber *playlimit  = [video valueForKey:OLCPlayerPlayTime];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path];
    
    if(!fileExists)
    {
        NSLog(@"OLCPlayer Error File not found: %@", fileURL.path);
    }
    
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
//    playerCtrl.player = [AVPlayer playerWithPlayerItem: playerItem];
//    playerCtrl.player.volume = volumeLevel;
    
    //video looping for same video
//    AVURLAsset *tAsset = [AVURLAsset assetWithURL:fileURL];
//    CMTimeRange tEditRange = CMTimeRangeMake(CMTimeMake(0, 600), CMTimeMake(tAsset.duration.value, tAsset.duration.timescale));
//    AVMutableComposition *tComposition = [[AVMutableComposition alloc] init];
//    for (int i = 0; i < 6; i++) { // Insert some copies.
//        [tComposition insertTimeRange:tEditRange ofAsset:tAsset atTime:tComposition.duration error:nil];
//    }
    
    AVAsset *composition = [self makeAssetComposition:fileURL forLimit:[playlimit floatValue]];
    AVPlayerItem *tAVPlayerItem = [[AVPlayerItem alloc] initWithAsset:composition];
    AVPlayer *tAVPlayer = [[AVPlayer alloc] initWithPlayerItem:tAVPlayerItem];
    playerCtrl.player = tAVPlayer;
    
    playerCtrl.player.volume = volumeLevel;
    
    
//    //loop option 2
//    AVAsset *composition = [self makeAssetComposition:fileURL];
//    // create an AVPlayer with your composition
//    AVPlayer* mp = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:composition]];
//    // Add the player to your UserInterface
//    // Create a PlayerLayer:
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:mp];
//    playerCtrl.player = mp;
    
//    [mp play];
    
    if ([self.delegate respondsToSelector:@selector(onVideoTrackChanged:)])
    {
        [[self delegate] onVideoTrackChanged:index];
    }
    
    [self play];
}

- (AVAsset*) makeAssetComposition:(NSURL*)  mURL forLimit:(float) limit{
    
    int numOfCopies = 0;
    
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVURLAsset* sourceAsset = [AVURLAsset URLAssetWithURL:mURL options:nil];
    
    float duration = CMTimeGetSeconds(sourceAsset.duration);
    
    numOfCopies    = floor(limit / duration);
    
    // calculate time
    CMTimeRange editRange = CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(sourceAsset.duration.value, sourceAsset.duration.timescale));
    
    NSError *editError;
    
    // and add into your composition
    BOOL result = [composition insertTimeRange:editRange ofAsset:sourceAsset atTime:composition.duration error:&editError];
    
    if (result)
    {
        for (int i = 0; i < numOfCopies; i++) {
            [composition insertTimeRange:editRange ofAsset:sourceAsset atTime:composition.duration error:&editError];
        }
    }
    
    return composition;
}

- (void) seekToTime:(double) time
{
    [playerCtrl.player pause];
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [playerCtrl.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [playerCtrl.player play];
}

#pragma mark - player events

-(void)itemDidFinishPlaying:(NSNotification *) notification
{
    if ([self.delegate respondsToSelector:@selector(onFinishPlaying:)])
    {
        [[self delegate] onFinishPlaying:playIndex];
    }
    
    if(doLoop)
        [self playVideAtIndex:playIndex];
    else
    {
        if(canPlayContinus)
        {
            if(currentplaytime >= playtime)
            {
                [self playNext];
            }
            else
                [self playVideAtIndex:playIndex];
        }
    }
    
    
}

- (void) updateTime:(NSTimer *) timer
{
    AVPlayerItem *currentItem = playerCtrl.player.currentItem;
    
    if(currentItem)
    {
        double startTime = CMTimeGetSeconds(currentItem.currentTime);
        double loadedDuration = CMTimeGetSeconds(currentItem.duration);
        
        if ([self.delegate respondsToSelector:@selector(onPlayInfoUpdate:withDuration:)])
        {
            [[self delegate] onPlayInfoUpdate:startTime withDuration:loadedDuration];
        }
    }
    
    
    
//    NSLog(@"Play Watcher: C:%f, F:%f", currentplaytime, playtime);
    
    if(self.isPlaying)
    {
        currentplaytime += OLC_UPDATETIMER_INTERVAL;
        
        if(canPlayContinus)
        {
            if(playtime > 0)
            {
                if(currentplaytime >= playtime)
                {
                    if(!doLoop)
                        [self  playNext];
                }
            }
        }
    }
}

@end
