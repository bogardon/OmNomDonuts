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
#import "LifeCounterNode.h"
#import "MainMenuScene.h"
#import "MissNode.h"
#import "PauseNode.h"
#import "SKNode+Control.h"
#import "ScoreCounterNode.h"
#import "ViewController.h"

static const CFTimeInterval kSlowestDeployPeriod = 1.2;
static const CFTimeInterval kFastestDeployPeriod = 0.3;
static const CFTimeInterval kExponentialDecayLambda = 1.0 / 100.0;
static const NSInteger kMaxLives = 5;
static const CGFloat kPadding = 4.0;

@interface GameScene ()<DonutStateDelegate>

@end

@implementation GameScene {
  ScoreCounterNode *_scoreCounter;
  LifeCounterNode *_lifeCounter;
  PauseNode *_pauseNode;

  CFTimeInterval _gameStartTime;
  CFTimeInterval _lastCurrentTime;
  CFTimeInterval _elapsedGameTime;
  CFTimeInterval _lastDeployTime;
}

- (instancetype)initWithSize:(CGSize)size {
  self = [super initWithSize:size];
  if (self) {
    [self createContent];
    [self resetGame];
  }
  return self;
}

#pragma mark - SKScene

- (void)update:(CFTimeInterval)currentTime {
  if (_lastCurrentTime == 0) {
    _lastCurrentTime = currentTime;
  }

  if (self.paused) {
    _lastCurrentTime = currentTime;
    return;
  }

  _elapsedGameTime += currentTime - _lastCurrentTime;
  _lastCurrentTime = currentTime;

  CFTimeInterval deployPeriod =
      MAX(kFastestDeployPeriod,
          kSlowestDeployPeriod * exp(-_elapsedGameTime * kExponentialDecayLambda));

  if (_elapsedGameTime - _lastDeployTime < deployPeriod) {
    return;
  }

  [self deployDonutAfterDelay:0 speed:1];

  _lastDeployTime = _elapsedGameTime;
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
      [self onDonutHit:donut];
      break;
    case kDonutStateMissed:
      [_lifeCounter decrementLives];
      if (!_lifeCounter.currentLives) {
        [self loseGame];
      }
      break;
  }
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  [self showMissAtPoint:[touch locationInNode:self]];
}

#pragma mark Private Methods

- (void)onDonutHit:(Donut *)donut {
  switch (donut.type) {
    case kDonutTypeRegular:
      _scoreCounter.score += 10;
      [donut fadeOut];
      break;
    case kDonutTypeDecelerator:
      break;
    case kDonutTypeBlackhole:
      break;
  }
}

- (void)onPause:(id)sender {
  self.view.paused ^= YES;
}

- (void)resetGame {
  _gameStartTime = 0;
  [_scoreCounter reset];
  [_lifeCounter reset];

  NSMutableArray *donuts = [NSMutableArray array];
  [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isKindOfClass:[Donut class]]) {
      [donuts addObject:obj];
    }
  }];
  [self removeChildrenInArray:donuts];
}

- (void)pauseGame:(BOOL)pause {
  self.paused = pause;
}

- (void)loseGame {
  MainMenuScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.view.bounds.size];
  mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5];
  [self.view presentScene:mainMenuScene transition:transition];
}

- (void)createContent {
  SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background_red"];
  background.anchorPoint = CGPointMake(0, 0);
  [self addChild:background];

  _scoreCounter = [ScoreCounterNode labelNodeWithFontNamed:@"HelveticaNeue"];
  _scoreCounter.fontColor = [SKColor darkTextColor];
  _scoreCounter.fontSize = 20;
  _scoreCounter.position =
      CGPointMake(CGRectGetMinX(self.frame) + kPadding, CGRectGetMaxY(self.frame) - kPadding);
  _scoreCounter.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  _scoreCounter.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [self addChild:_scoreCounter];

  _lifeCounter = [[LifeCounterNode alloc] initWithMaxLives:kMaxLives];
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

- (void)deployDonutAfterDelay:(CFTimeInterval)delay speed:(CGFloat)speed {
  Donut *donut = [[Donut alloc] initWithType:kDonutTypeRegular];
  donut.delegate = self;
  CGPoint position =
      CGPointMake(arc4random() % (int)self.size.width, arc4random() % ((int)self.size.height - 20));
  donut.position = position;
  [self addChild:donut];

  [donut expandAndContract];
}

- (void)showMissAtPoint:(CGPoint)point {
  MissNode *shape = [MissNode node];
  shape.position = point;
  [shape showAndHide];
  [self addChild:shape];
}

@end
