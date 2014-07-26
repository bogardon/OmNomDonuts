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

@interface ViewController () <MainMenuSceneDelegate>

@property (nonatomic, readonly) SKView *skView;
@property (nonatomic, strong) MainMenuScene *mainMenuScene;
@property (nonatomic, strong) GameScene *gameScene;

- (void)createScenes;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createScenes];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;

    [self showMainMenuScene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Private

- (SKView *)skView
{
    return (SKView *)self.view;
}

- (void)createScenes
{
    self.mainMenuScene = [MainMenuScene sceneWithSize:self.skView.bounds.size];
    self.mainMenuScene.delegate = self;
    self.mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;

    self.gameScene = [GameScene sceneWithSize:self.skView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
}

#pragma mark - Pubilc

- (void)showMainMenuScene
{
    [self.skView presentScene:self.mainMenuScene];
}

- (void)showGameScene
{
    [self.skView presentScene:self.gameScene transition:[SKTransition crossFadeWithDuration:1]];
    [self.gameScene resetGame];
}

#pragma mark - MainMenuSceneDelegate

- (void)mainMenuSceneDidPlayGame:(MainMenuScene *)mainMenuScene
{
    [self showGameScene];
}

@end
