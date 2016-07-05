#import "GameScene.h"

#import "MainMenuScene.h"
#import "SKNode+Control.h"
#import "ViewController.h"
#import "PlayNode.h"

@interface MainMenuScene ()
@end

@implementation MainMenuScene {

}

- (id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];

    PlayNode *play = [[PlayNode alloc] init];
    play.userInteractionEnabled = YES;
    play.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:play];

    [play addTarget:self selector:@selector(onPlay:)];
  }
  return self;
}

#pragma mark Private Methods

- (void)onPlay:(id)sender {
  GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
  gameScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition crossFadeWithDuration:0.5];
  [self.view presentScene:gameScene transition:transition];
}

@end
