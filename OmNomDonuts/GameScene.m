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

@implementation GameScene {
  ScoreCounterNode *_scoreCounter;
  LifeCounterNode *_lifeCounter;
  PauseNode *_pauseNode;

  NSInteger _numberOfMisses;
  NSInteger _score;

  CFTimeInterval _gameStartTime;
  CFTimeInterval _lastCurrentTime;
  CFTimeInterval _elapsedGameTime;
  CFTimeInterval _lastDeployTime;
}

- (instancetype)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
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

#pragma mark Private Methods

- (void)onPause {
  self.view.paused ^= YES;
}

- (void)resetGame {
  _gameStartTime = 0;
  _score = 0;
  _numberOfMisses = 0;
  [_scoreCounter reset];
  [_lifeCounter reset];

  NSMutableArray *donuts = [NSMutableArray array];
  [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isKindOfClass:Donut.class]) {
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
  SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5f];
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
      CGPointMake(CGRectGetMinX(self.frame) + 5, CGRectGetMaxY(self.frame) - 5);
  _scoreCounter.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  _scoreCounter.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [self addChild:_scoreCounter];

  _lifeCounter = [[LifeCounterNode alloc] initWithMaxLives:kMaxLives];
  CGRect accumulatedFrame = [_lifeCounter calculateAccumulatedFrame];
  _lifeCounter.position =
      CGPointMake(CGRectGetMidX(self.frame) - accumulatedFrame.size.width / 2,
                  CGRectGetMaxY(self.frame) - accumulatedFrame.size.height / 2 - 5);
  [self addChild:_lifeCounter];

  _pauseNode = [[PauseNode alloc] init];
  accumulatedFrame = [_pauseNode calculateAccumulatedFrame];
  _pauseNode.position = CGPointMake(CGRectGetMaxX(self.frame) - accumulatedFrame.size.width - 5,
                                    CGRectGetMaxY(self.frame) - accumulatedFrame.size.height - 5);
  [_pauseNode addTarget:self selector:@selector(onPause)];
  [self addChild:_pauseNode];
}

- (void)deployDonutAfterDelay:(CFTimeInterval)delay speed:(CGFloat)speed {
  Donut *donut = [Donut spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"donut2"]];
  donut.size = CGSizeMake(40, 40);
  donut.name = @"donut";

  CGPoint position =
      CGPointMake(arc4random() % (int)self.size.width, arc4random() % ((int)self.size.height - 20));
  donut.position = position;
  [donut setScale:0];
  [self addChild:donut];

  SKAction *wait = [SKAction waitForDuration:delay];

  SKAction *scaleUp = [SKAction scaleTo:1 duration:1.2];
  scaleUp.timingMode = SKActionTimingEaseOut;

  SKAction *scaleDown = [SKAction scaleTo:0 duration:1.2];
  scaleDown.timingMode = SKActionTimingEaseIn;

  NSArray *actions = @[
    wait,
    scaleUp,
    scaleDown,
    [SKAction runBlock:^{
      [self missDonut:donut];
    }],
    [SKAction removeFromParent]
  ];
  SKAction *sequence = [SKAction sequence:actions];
  [donut runAction:sequence];
}

- (void)hitDonut:(Donut *)donut {
  [donut removeAllActions];

  NSArray *actions = @[ [SKAction fadeOutWithDuration:0.2], [SKAction removeFromParent] ];
  SKAction *sequence = [SKAction sequence:actions];
  [donut runAction:sequence];

  _scoreCounter.score += 10;
}

- (void)missDonut:(Donut *)donut {
  _numberOfMisses++;

  [_lifeCounter decrementLives];

  if (_numberOfMisses == 5) {
    [self loseGame];
  }
}

- (void)slowDonutsForInterval:(CFTimeInterval)interval {
  [self enumerateChildNodesWithName:@"donut"
                         usingBlock:^(SKNode *node, BOOL *stop) {
                           node.speed = 0.5;
                         }];
}

- (void)showMissAtPoint:(CGPoint)point {
  MissNode *shape = [MissNode node];
  shape.position = point;
  [shape showAndHide];
  [self addChild:shape];
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
    CGPoint point = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:point];
    if ([node.name isEqualToString:@"donut"]) {
      Donut *donut = (Donut *)node;
      if (!donut.isHit) {
        donut.hit = YES;
        [self hitDonut:donut];
      }
    } else {
      [self showMissAtPoint:point];
    }
  }];
}

@end
