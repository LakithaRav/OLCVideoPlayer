//
//  OLCViewController.h
//  OLCVideoPlayer
//
//  Created by Lakitha Sam on 08/02/2015.
//  Copyright (c) 2015 Lakitha Sam. All rights reserved.
//

#import "OLCVideoPlayer.h"

@import UIKit;

@interface OLCViewController : UIViewController
@property (weak, nonatomic) IBOutlet OLCVideoPlayer *vidplayer;

@property (weak, nonatomic) IBOutlet UIProgressView *sldProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrent;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UISlider *sldVolume;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;

@end
