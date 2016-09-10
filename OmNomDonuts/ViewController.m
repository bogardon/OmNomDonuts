//
//  ViewController.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <SpriteKit/SpriteKit.h>

#import "MainMenuScene.h"

@interface ViewController ()

@property(nonatomic, readonly) SKView *view;

@end

@implementation ViewController {
  AVAudioPlayer *_bgmPlayer;
}

@dynamic view;

- (void)viewDidLoad {
  [super viewDidLoad];

  NSURL *bgmURL =
      [[NSBundle mainBundle] URLForResource:@"omnomdonuts_theme_draft_105bpm"
                              withExtension:@"m4a"];
  _bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:bgmURL error:nil];
  _bgmPlayer.numberOfLoops = -1;
//  [_bgmPlayer play];

  self.view.showsFPS = YES;
  self.view.showsNodeCount = YES;

  MainMenuScene *mainMenuScene = [MainMenuScene sceneWithSize:self.view.bounds.size];
  mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
  [self.view presentScene:mainMenuScene];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
