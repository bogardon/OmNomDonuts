//
//  MyScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"

#import "MainMenuScene.h"
#import "MenuButtonNode.h"
#import "SKNode+Control.h"
#import "ViewController.h"

@interface MainMenuScene ()
@end

@implementation MainMenuScene {
  MenuButtonNode *_playButton;
}

- (id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];

    _playButton = [MenuButtonNode labelNodeWithText:@"Play"];
    _playButton.userInteractionEnabled = YES;
    _playButton.fontColor = [SKColor darkTextColor];
    _playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_playButton];

    [_playButton addTarget:self selector:@selector(onPlay:)];
  }
  return self;
}

#pragma mark Private Methods

- (void)onPlay:(id)sender {
  GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
  gameScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *flip = [SKTransition crossFadeWithDuration:0.5];
  [self.view presentScene:gameScene transition:flip];
}

@end
