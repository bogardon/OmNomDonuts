//
//  GameScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//
//

#import "GameScene.h"

#import <math.h>

#import "Donut.h"
#import "GameConfig.h"
#import "LifeCounterNode.h"
#import "MainMenuScene.h"
#import "MissNode.h"
#import "PauseNode.h"
#import "SKNode+Control.h"
#import "SKScene+Utils.h"
#import "ScoreCounterNode.h"
#import "ViewController.h"

static const CGFloat kPadding = 4.0;

@interface GameScene ()<DonutStateDelegate>
@end

@implementation GameScene {
  ScoreCounterNode *_scoreCounter;
  LifeCounterNode *_lifeCounter;
  PauseNode *_pauseNode;
  GameConfig *_gameConfig;
}

- (instancetype)initWithSize:(CGSize)size {
  self = [super initWithSize:size];
  if (self) {
    _gameConfig = [[GameConfig alloc] init];

    self.backgroundColor = [SKColor whiteColor];

    [self createContent];
    [self resetGame];
    [self startGame];
  }
  return self;
}

#pragma mark - SKScene

- (void)update:(CFTimeInterval)currentTime {
  // Figure out if we even need this.
}

#pragma mark DonutStateDelegate

- (void)donutStateDidChange:(Donut *)donut {
  switch (donut.state) {
    case kDonutStateInitial:
      break;
    case kDonutStateExpanding:
      break;
    case kDonutStateContracting:
      break;
    case kDonutStateHit:
      _scoreCounter.score += donut.value;
      break;
    case kDonutStateMissed:
      break;
  }
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInNode:self];
  Donut *donutToHit;
  for (Donut *donut in [self.pendingDonuts reverseObjectEnumerator]) {
    if ([donut isPointWithinSmallestTapRadius:point]) {
      donutToHit = donut;
      break;
    }
  }

  if (donutToHit) {
    [donutToHit touchesEnded:touches withEvent:event];
  } else {
    [self showMissAtPoint:point];
  }
}

#pragma mark Private Methods

- (void)onPause:(id)sender {
  self.view.paused ^= YES;
}

- (void)startGame {
  SKAction *wait = [SKAction waitForDuration:_gameConfig.deployPeriod];
  SKAction *deploy = [SKAction performSelector:@selector(onDeployTimer) onTarget:self];
  SKAction *sequence = [SKAction sequence:@[deploy, wait]];
  [self runAction:[SKAction repeatActionForever:sequence]];
}

- (void)onDeployTimer {
  for (NSInteger i = 0; i < _gameConfig.numberOfDonutsPerDeploy; i++) {
    [self deployDonutWithType:kDonutTypeRegular];
  }

  if (arc4random() % 4 == 0) {
    [self deployDonutWithType:kDonutTypeDecelerator];
  }
  if (arc4random() % 4 == 0) {
    [self deployDonutWithType:kDonutTypeBlackhole];
  }
}

- (void)deployDonutWithType:(DonutType)type {
  Donut *donut = [[Donut alloc] initWithType:type];
  donut.delegate = self;
  CGFloat halfDimension = donut.size.width / 2.0;
  CGPoint position =
      CGPointMake(halfDimension + arc4random() % (int)(self.size.width - 2 * halfDimension),
                  halfDimension + arc4random() % (int)(self.size.height - 2 * halfDimension));
  donut.position = position;
  [self addChild:donut];
  [donut expandAndContract];
}

- (void)resetGame {
  [_scoreCounter reset];
  [_lifeCounter reset];

  [self removeAllActions];
  [self removeChildrenInArray:self.allDonuts];
}

- (void)loseGame {
  MainMenuScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.view.bounds.size];
  mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
  [self.view presentScene:mainMenuScene transition:transition];
}

- (void)createContent {
  _scoreCounter = [ScoreCounterNode labelNodeWithFontNamed:@"HelveticaNeue"];
  _scoreCounter.fontColor = [SKColor darkTextColor];
  _scoreCounter.fontSize = 20;
  _scoreCounter.position =
      CGPointMake(CGRectGetMinX(self.frame) + kPadding, CGRectGetMaxY(self.frame) - kPadding);
  _scoreCounter.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  _scoreCounter.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [self addChild:_scoreCounter];

  _lifeCounter = [[LifeCounterNode alloc] initWithMaxLives:_gameConfig.maxLives];
  CGRect accumulatedFrame = [_lifeCounter calculateAccumulatedFrame];
  _lifeCounter.position =
      CGPointMake(CGRectGetMidX(self.frame) - accumulatedFrame.size.width / 2,
                  CGRectGetMaxY(self.frame) - accumulatedFrame.size.height / 2 - kPadding);
  [self addChild:_lifeCounter];

  _pauseNode = [[PauseNode alloc] init];
  accumulatedFrame = [_pauseNode calculateAccumulatedFrame];
  _pauseNode.position =
      CGPointMake(CGRectGetMaxX(self.frame) - accumulatedFrame.size.width - kPadding,
                  CGRectGetMaxY(self.frame) - accumulatedFrame.size.height - kPadding);
  [_pauseNode addTarget:self selector:@selector(onPause:)];
  [self addChild:_pauseNode];
}

- (void)showMissAtPoint:(CGPoint)point {
  MissNode *shape = [MissNode node];
  shape.position = point;
  [shape showAndHide];
  [self addChild:shape];
}

@end
