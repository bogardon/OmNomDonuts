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
#import "NSArray+Utils.h"
#import "PauseNode.h"
#import "SKNode+Control.h"
#import "ScoreCounterNode.h"
#import "ViewController.h"

static const NSInteger kMaxLives = 5;
static const CGFloat kPadding = 4.0;
static const NSTimeInterval kDeployPeriod = 3.0;
static NSString *const kDecelerateActionKey = @"kDecelerateActionKey";
static NSString *const kDeployActionKey = @"kDeployActionKey";

@interface GameScene ()<DonutStateDelegate>
@property(nonatomic, assign) CGFloat currentGameSpeed;
@end

@implementation GameScene {
  ScoreCounterNode *_scoreCounter;
  LifeCounterNode *_lifeCounter;
  PauseNode *_pauseNode;
}

- (instancetype)initWithSize:(CGSize)size {
  self = [super initWithSize:size];
  if (self) {
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
      [self onDonutHit:donut];
      break;
    case kDonutStateMissed:
      if (donut.type == kDonutTypeRegular) {
        [_lifeCounter decrementLives];
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

- (void)setCurrentGameSpeed:(CGFloat)currentGameSpeed {
  _currentGameSpeed = currentGameSpeed;
  NSLog(@"%f", currentGameSpeed);
  [[self pendingDonuts]
      enumerateObjectsUsingBlock:^(Donut *donut, NSUInteger idx, BOOL *_Nonnull stop) {
        donut.speed = currentGameSpeed;
      }];
  [self actionForKey:kDeployActionKey].speed = currentGameSpeed;
}

- (NSArray *)allDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(id object) {
    return [object isKindOfClass:[Donut class]];
  }];
}

- (NSArray *)pendingDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(Donut *donut) {
    return [donut isKindOfClass:[Donut class]] && donut.state != kDonutStateHit &&
           donut.state != kDonutStateMissed;
  }];
}

- (void)onDonutHit:(Donut *)donut {
  switch (donut.type) {
    case kDonutTypeRegular:
      _scoreCounter.score += 10;
      [donut fadeOut];
      break;
    case kDonutTypeDecelerator: {
      [self removeActionForKey:kDecelerateActionKey];
      self.currentGameSpeed = 0.5;
      SKAction *wait = [SKAction waitForDuration:5.0];
      SKAction *revert = [SKAction runBlock:^{
        self.currentGameSpeed = 1.0;
      }];
      [self runAction:[SKAction sequence:@[wait, revert]] withKey:kDecelerateActionKey];
      [donut fadeOut];
      break;
    }
    case kDonutTypeBlackhole:
      break;
  }
}

- (void)onPause:(id)sender {
  self.view.paused ^= YES;
}

- (void)startGame {
  SKAction *wait = [SKAction waitForDuration:kDeployPeriod];
  SKAction *deploy = [SKAction performSelector:@selector(onDeployTimer) onTarget:self];
  SKAction *sequence = [SKAction sequence:@[deploy, wait]];
  [self runAction:[SKAction repeatActionForever:sequence] withKey:kDeployActionKey];
}

- (void)onDeployTimer {
  for (NSInteger i = 0; i < 3; i++) {
    [self deployDonutWithType:kDonutTypeRegular];
  }
  if (self.currentGameSpeed == 1 && arc4random() % 4 == 0) {
    [self deployDonutWithType:kDonutTypeDecelerator];
  }
}

- (void)deployDonutWithType:(DonutType)type {
  Donut *donut = [[Donut alloc] initWithType:type];
  donut.delegate = self;
  CGPoint position =
      CGPointMake(arc4random() % (int)self.size.width, arc4random() % ((int)self.size.height - 20));
  donut.position = position;
  [self addChild:donut];

  [donut expandAndContract];
  donut.speed = _currentGameSpeed;
}

- (void)resetGame {
  [_scoreCounter reset];
  [_lifeCounter reset];
  _currentGameSpeed = 1.0;

  [self removeAllActions];
  [self removeChildrenInArray:[self allDonuts]];
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

- (void)showMissAtPoint:(CGPoint)point {
  MissNode *shape = [MissNode node];
  shape.position = point;
  [shape showAndHide];
  [self addChild:shape];
}

@end
