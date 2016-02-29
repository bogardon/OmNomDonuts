//
//  MyScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "MainMenuScene.h"
#import "ViewController.h"

@interface MainMenuScene ()
@end

@implementation MainMenuScene

- (id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];
  }
  return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
  gameScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *flip = [SKTransition flipVerticalWithDuration:0.5f];
  [self.view presentScene:gameScene transition:flip];
}

@end
