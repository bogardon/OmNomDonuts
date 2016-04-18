//
//  GameScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//
//

#import "GameScene.h"

#import <math.h>

#import "BlackholeDonut.h"
#import "BouncingDonut.h"
#import "DeceleratorDonut.h"
#import "GameConfig.h"
#import "LifeCounterNode.h"
#import "MainMenuScene.h"
#import "MissNode.h"
#import "PauseNode.h"
#import "RegularDonut.h"
#import "SKNode+Control.h"
#import "SKScene+Utils.h"
#import "ScoreCounterNode.h"
#import "ViewController.h"

static const uint32_t kStaticCategory = 0x1 << 0;
static const uint32_t kMovingCategory = 0x1 << 1;
static const uint32_t kEdgeCategory = 0x1 << 2;
static NSString *const kExpandAndContractActionKey = @"kExpandAndContractActionKey";
static NSString *const kResetContractSpeedKey = @"kResetContractSpeedKey";
static const CGFloat kPadding = 4.0;

@interface GameScene ()<SKPhysicsContactDelegate>
@end

@implementation GameScene {
  ScoreCounterNode *_scoreCounter;
  LifeCounterNode *_lifeCounter;
  PauseNode *_pauseNode;
  GameConfig *_gameConfig;

  BouncingDonut *_activeBouncingDonut;
}

- (instancetype)initWithSize:(CGSize)size {
  self = [super initWithSize:size];
  if (self) {
    _gameConfig = [[GameConfig alloc] init];

    self.backgroundColor =
        [SKColor colorWithRed:204.0 / 255.0 green:234.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.restitution = 1;
    self.physicsBody.friction = 0;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsBody.categoryBitMask = kEdgeCategory;
    self.physicsWorld.contactDelegate = self;

    [self createContent];
    [self resetGame];
    [self startGame];
  }
  return self;
}

#pragma mark SKScene

- (void)update:(CFTimeInterval)currentTime {
  // Figure out if we even need this.
}

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInNode:self];
  for (SKSpriteNode<Donut> *donut in [self.pendingDonuts reverseObjectEnumerator]) {
    CGFloat distanceToCenter = hypot(point.x - donut.position.x, point.y - donut.position.y);
    if (distanceToCenter <= MAX(donut.size.width / 2, 10)) {
      [self hitDonut:donut point:point];
      return;
    }
  }

  [self showMissAtPoint:point];
}

#pragma mark SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
  SKSpriteNode<Donut> *donut = (SKSpriteNode<Donut> *)
      (contact.bodyA.categoryBitMask == kMovingCategory ? contact.bodyB.node : contact.bodyA.node);
  [self hitDonut:donut point:contact.contactPoint];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
}

#pragma mark Private Methods

- (void)hitDonut:(SKSpriteNode<Donut> *)donut point:(CGPoint)point {
  donut.hit = YES;
  _scoreCounter.score += donut.value;

  if ([donut isKindOfClass:[RegularDonut class]]) {
    [self fadeOutDonut:donut];
  } else if ([donut isKindOfClass:[DeceleratorDonut class]]) {
    [self fadeOutDonut:donut];
    _gameConfig.contractSpeed = 0.3;
    for (SKSpriteNode<Donut> *otherDonut in self.pendingDonuts) {
      [otherDonut actionForKey:kExpandAndContractActionKey].speed = _gameConfig.contractSpeed;
    }
    SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:5.0],
                                              [SKAction runBlock:^{
      _gameConfig.contractSpeed = 1.0;
    }]]];
    [self removeActionForKey:kResetContractSpeedKey];
    [self runAction:sequence withKey:kResetContractSpeedKey];
  } else if ([donut isKindOfClass:[BlackholeDonut class]]) {
    [self fadeOutDonut:donut];
    for (SKSpriteNode<Donut> *otherDonut in self.pendingDonuts) {
      if (donut == otherDonut) {
        continue;
      }
      if (hypot(otherDonut.position.x - donut.position.x,
                otherDonut.position.y - donut.position.y) < 120) {
        otherDonut.hit = YES;
        _scoreCounter.score += otherDonut.value;
        [self gravitateDonut:otherDonut towardsPoint:donut.position];
      }
    }
  } else if ([donut isKindOfClass:[BouncingDonut class]]) {
    [donut removeAllActions];
    SKAction *sequence = [SKAction sequence:@[
                                              [SKAction scaleTo:1.0 duration:0.2],
                                              [SKAction waitForDuration:3.0],
                                              [SKAction fadeOutWithDuration:0.2],
                                              [SKAction removeFromParent]
                                              ]];
    [donut runAction:sequence];
    donut.physicsBody.contactTestBitMask = kStaticCategory;
    CGFloat dx = point.x - donut.position.x;
    CGFloat dy = point.y - donut.position.y;
    CGFloat angle = atan2(dy, dx);
    CGVector vector = CGVectorMake(500 * cos(angle), 500 * sin(angle));
    donut.physicsBody.velocity = vector;
  }
}

- (void)onPause:(id)sender {
  self.view.paused ^= YES;
}

- (void)startGame {
  [self scheduleNextDeploy];
}

- (void)scheduleNextDeploy {
  SKAction *wait = [SKAction waitForDuration:_gameConfig.deployPeriod];
  SKAction *deploy = [SKAction performSelector:@selector(onDeployTimer) onTarget:self];
  __weak GameScene *weakSelf = self;
  SKAction *reschedule = [SKAction runBlock:^{
    [weakSelf scheduleNextDeploy];
  }];
  SKAction *sequence = [SKAction sequence:@[deploy, wait, reschedule]];
  [self runAction:sequence];
}

- (void)onDeployTimer {
  for (NSInteger i = 0; i < _gameConfig.numberOfDonutsPerDeploy; i++) {
    [self runAction:[SKAction waitForDuration:1.5 withRange:3.0]
         completion:^{
           [self deployRegularDonut];
         }];
  }

//  if (arc4random() % 4 == 0) {
    [self deployDeceleratorDonut];
//  }

//  if (arc4random() % 4 == 0) {
    [self deployBlackholeDonut];
//  }

//  if (arc4random() % 4 == 0) {
    [self deployBouncingDonut];
//  }
}

- (void)deployRegularDonut {
  RegularDonut *donut = [[RegularDonut alloc] init];
  donut.size = CGSizeMake(100, 100);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [self addChild:donut];
  [self randomlyPositionDonut:donut];
  [self expandAndContractDonut:donut];
}

- (void)deployDeceleratorDonut {
  DeceleratorDonut *donut = [[DeceleratorDonut alloc] init];
  donut.size = CGSizeMake(100, 100);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [self addChild:donut];
  [self randomlyPositionDonut:donut];
  [self expandAndContractDonut:donut];
}

- (void)deployBlackholeDonut {
  BlackholeDonut *donut = [[BlackholeDonut alloc] init];
  donut.size = CGSizeMake(100, 100);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [self addChild:donut];
  [self randomlyPositionDonut:donut];
  [self expandAndContractDonut:donut];
}

- (void)deployBouncingDonut {
  BouncingDonut *donut = [[BouncingDonut alloc] init];
  donut.size = CGSizeMake(100, 100);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.categoryBitMask = kMovingCategory;
  donut.physicsBody.collisionBitMask = kEdgeCategory;
  donut.physicsBody.mass = 0;
  donut.physicsBody.linearDamping = 0;
  donut.physicsBody.angularDamping = 0;
  donut.physicsBody.restitution = 1;
  donut.physicsBody.friction = 0;
  [self randomlyPositionDonut:donut];
  [self addChild:donut];

  [self expandAndContractDonut:donut];
}

- (void)randomlyPositionDonut:(SKSpriteNode<Donut> *)donut {
  CGFloat halfDimension = donut.size.width / 2.0;
  CGPoint position =
      CGPointMake(halfDimension + arc4random() % (int)(self.size.width - 2 * halfDimension),
                  halfDimension + arc4random() % (int)(self.size.height - 2 * halfDimension));
  donut.position = position;
}

- (void)expandAndContractDonut:(SKSpriteNode<Donut> *)donut {
  [donut setScale:0];

  SKAction *scaleUp = [SKAction scaleTo:1 duration:0.3];
  scaleUp.timingFunction = ^float(float t) {
    CGFloat s = 1.70158;
    CGFloat f = 1.0 - t;
    return 1.0 - ((s + 1.0) * f - s) * f * f;
  };
  SKAction *scaleDown = [SKAction scaleTo:0 duration:donut.contractDuration];
  scaleDown.speed = _gameConfig.contractSpeed;

  NSArray *actions = @[scaleUp, scaleDown, [SKAction removeFromParent]];
  SKAction *sequence = [SKAction sequence:actions];
  [donut runAction:sequence withKey:kExpandAndContractActionKey];
}

- (void)fadeOutDonut:(SKSpriteNode<Donut> *)donut {
  [donut removeAllActions];
  NSArray *actions = @[[SKAction fadeOutWithDuration:0.2], [SKAction removeFromParent]];
  SKAction *sequence = [SKAction sequence:actions];
  [donut runAction:sequence];
}

- (void)gravitateDonut:(SKSpriteNode<Donut> *)donut towardsPoint:(CGPoint)point {
  [donut removeAllActions];
  SKAction *group =
      [SKAction group:@[[SKAction moveTo:point duration:0.2],
                        [SKAction scaleTo:0 duration:0.2],
                        [SKAction fadeOutWithDuration:0.2]]];
  SKAction *sequence = [SKAction sequence:@[group, [SKAction removeFromParent]]];
  [donut runAction:sequence];
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
