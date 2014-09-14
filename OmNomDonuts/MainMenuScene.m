//
//  MyScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"

@interface MainMenuScene ()
@property (nonatomic, assign) BOOL contentCreated;
@end

@implementation MainMenuScene

-(id)initWithSize:(CGSize)size {    
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
  }
  return self;
}

- (void)didMoveToView:(SKView *)view {
  if (!self.contentCreated) {
    self.contentCreated = YES;

  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
  gameScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *flip = [SKTransition flipVerticalWithDuration:0.5f];
  [self.view presentScene:gameScene transition:flip];
}

@end
