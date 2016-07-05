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

#import "GameScene.h"
#import "MainMenuScene.h"

@interface ViewController ()

@property(nonatomic, readonly) SKView *skView;

@end

@implementation ViewController {
  AVAudioPlayer *_bgmPlayer;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSURL *bgmURL =
      [[NSBundle mainBundle] URLForResource:@"omnomdonuts_theme_draft_105bpm"
                              withExtension:@"m4a"];
  _bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:bgmURL error:nil];
  _bgmPlayer.numberOfLoops = -1;
  [_bgmPlayer play];

  self.skView.showsFPS = YES;
  self.skView.showsNodeCount = YES;

  MainMenuScene *mainMenuScene = [MainMenuScene sceneWithSize:self.skView.bounds.size];
  mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
  [self.skView presentScene:mainMenuScene];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

#pragma mark - Private Methods

- (SKView *)skView {
  return (SKView *)self.view;
}

@end
