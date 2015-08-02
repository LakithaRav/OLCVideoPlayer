//
//  OLCViewController.m
//  OLCVideoPlayer
//
//  Created by Lakitha Sam on 08/02/2015.
//  Copyright (c) 2015 Lakitha Sam. All rights reserved.
//

#import "OLCViewController.h"

@interface OLCViewController ()<OLCVideoPlayerDelegate>

@end

@implementation OLCViewController
{
    NSArray *playlist;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.vidplayer setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationClosing:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpening:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self loadVideosToPlayer];
    
    [self.vidplayer continusPlay:YES];
    [self.vidplayer shuffleVideos:YES];
}

#pragma mark - OLCVideoPlayer Init

- (void) loadVideosToPlayer
{
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *video = nil;
    
    //Video 1
    NSURL *fileURL1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SampleVideo_1" ofType:@"mp4"]];
    video = [[NSMutableDictionary alloc] init];
    [video setObject:fileURL1 forKey:OLCPlayerVideoURL];
    [video setValue:@0 forKey:OLCPlayerPlayTime];
    [videos addObject:video];

    //Video 2
    NSURL *fileURL2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SampleVideo_2" ofType:@"mp4"]];
    video = [[NSMutableDictionary alloc] init];
    [video setObject:fileURL2 forKey:OLCPlayerVideoURL];
    [video setValue:@0 forKey:OLCPlayerPlayTime];
    [videos addObject:video];

    //Video 3
    NSURL *fileURL3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SampleVideo_3" ofType:@"mp4"]];
    video = [[NSMutableDictionary alloc] init];
    [video setObject:fileURL3 forKey:OLCPlayerVideoURL];
    [video setValue:@0 forKey:OLCPlayerPlayTime];
    [videos addObject:video];
    
    playlist = videos;
    
    [self.vidplayer playVideos:playlist];
}

#pragma mark - OLCVideoPlayer Controlls

- (IBAction)btnPlayPauseClicked:(id)sender {
    
    if([self.vidplayer isPlaying])
    {
        [self.vidplayer pause];
    }
    else
    {
        [self.vidplayer play];
    }
}

- (IBAction)btnNextClicked:(id)sender {
    
    [self.vidplayer playNext];
}

- (IBAction)btnPreviousClicked:(id)sender {
    
    [self.vidplayer playPrevious];
}

- (IBAction)sldVolumeChanged:(id)sender {
    
    float volume = ((UISlider*) sender).value;
    [self.vidplayer setVolume:volume];
}

- (IBAction)btnStopClicked:(id)sender {
    
    [self.vidplayer shutdown];
}

#pragma mark - OLCVideoPlayer Delegates

- (void) onVideoTrackChanged:(NSUInteger)index
{
    self.sldVolume.value = [self.vidplayer getVolume];
}

- (void) onFinishPlaying:(NSUInteger)index
{
    
}

- (void) onPause:(NSUInteger)index
{
    [self.btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
}

- (void) onPlay:(NSUInteger)index
{
    [self.btnPlayPause setTitle:@"Pause" forState:UIControlStateNormal];
}

//this get called every 0.5 seconds with video duration and current playtime so we can update our progress bars
- (void) onPlayInfoUpdate:(double)current withDuration:(double)duration
{
    float progress = ( current / duration );
    self.sldProgress.progress = progress;
    
    self.lblCurrent.text = [self stringFromSeconds:current];
    self.lblDuration.text = [self stringFromSeconds:duration];
}

#pragma mark - notifications

- (void) applicationClosing:(NSNotification *)notification
{
    [self.vidplayer playInBackground];
}

- (void) applicationOpening:(NSNotification *)notification
{
    [self.vidplayer playInForeground];
}

#pragma mark - private

- (NSString *) stringFromSeconds:(double) value
{
    NSTimeInterval interval = value;
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

@end
