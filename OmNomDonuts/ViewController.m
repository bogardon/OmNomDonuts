//
//  ViewController.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MainMenuScene.h"
#import "GameScene.h"

@interface ViewController ()

@property (nonatomic, readonly) SKView *skView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.skView.showsFPS = YES;
  self.skView.showsNodeCount = YES;

  MainMenuScene *mainMenuScene = [MainMenuScene sceneWithSize:self.skView.bounds.size];
  mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
  [self.skView presentScene:mainMenuScene];
}

- (BOOL)shouldAutorotate {
  return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Private

- (SKView *)skView {
  return (SKView *)self.view;
}

@end
