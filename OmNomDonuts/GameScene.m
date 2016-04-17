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
#import "Catapult.h"
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];

  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInNode:self];
  BouncingDonut *potentialBouncingDonut = (BouncingDonut *)[self nodeAtPoint:point];

  if ([potentialBouncingDonut isKindOfClass:[BouncingDonut class]] &&
      !potentialBouncingDonut.physicsBody.contactTestBitMask) {
    _activeBouncingDonut = (BouncingDonut *)potentialBouncingDonut;

    [_activeBouncingDonut removeAllActions];
    [_activeBouncingDonut runAction:[SKAction scaleTo:1.0 duration:0.2]];

    SKShapeNode *finger = [SKShapeNode shapeNodeWithCircleOfRadius:1.0];
    finger.fillColor = [SKColor clearColor];
    finger.position = point;
    finger.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1.0];
    finger.physicsBody.dynamic = NO;
    [self addChild:finger];
    _activeBouncingDonut.catapult.finger = finger;

    SKPhysicsJointSpring *spring = [SKPhysicsJointSpring jointWithBodyA:_activeBouncingDonut.physicsBody bodyB:finger.physicsBody anchorA:_activeBouncingDonut.position anchorB:finger.position];
    spring.damping = 0.2;
    spring.frequency = 1;
    [self.physicsWorld addJoint:spring];
    _activeBouncingDonut.catapult.fingerToDonutJoint = spring;
  }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  UITouch *touch = [touches anyObject];
  CGPoint p1 = [touch locationInNode:self];
  CGPoint p2 = [touch previousLocationInNode:self];

  if (_activeBouncingDonut) {
    SKNode *finger = _activeBouncingDonut.catapult.finger;
    finger.position = CGPointMake(finger.position.x + p1.x - p2.x, finger.position.y + p1.y - p2.y);
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  if (_activeBouncingDonut) {
    [self.physicsWorld removeJoint:_activeBouncingDonut.catapult.fingerToDonutJoint];
    _activeBouncingDonut.catapult.fingerToDonutJoint = nil;

    [_activeBouncingDonut.catapult.finger removeFromParent];
    _activeBouncingDonut.catapult.finger = nil;

    SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:3.0], [SKAction fadeOutWithDuration:0.2], [SKAction removeFromParent]]];
    [_activeBouncingDonut runAction:sequence];
    _activeBouncingDonut.physicsBody.contactTestBitMask = kStaticCategory;

    _activeBouncingDonut = nil;

    return;
  }

  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInNode:self];
  for (SKSpriteNode<Donut> *donut in [self.pendingDonuts reverseObjectEnumerator]) {
    CGFloat distanceToCenter = hypot(point.x - donut.position.x, point.y - donut.position.y);
    if (distanceToCenter <= MAX(donut.size.width / 2, 10)) {
      [self hitDonut:donut];
      return;
    }
  }

  [self showMissAtPoint:point];
}

#pragma mark SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
  SKSpriteNode<Donut> *donut = (SKSpriteNode<Donut> *)
      (contact.bodyA.categoryBitMask == kMovingCategory ? contact.bodyB.node : contact.bodyA.node);
  [self hitDonut:donut];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
}

#pragma mark Private Methods

- (void)hitDonut:(SKSpriteNode<Donut> *)donut {
  donut.hit = YES;
  _scoreCounter.score += donut.value;

  if ([donut isKindOfClass:[RegularDonut class]]) {
    [self fadeOutDonut:donut];
  } else if ([donut isKindOfClass:[DeceleratorDonut class]]) {
    [self fadeOutDonut:donut];
    for (SKSpriteNode<Donut> *otherDonut in self.pendingDonuts) {
      [self slowDownDonut:otherDonut];
    }
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
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [self addChild:donut];
  [self randomlyPositionDonut:donut];
  [self expandAndContractDonut:donut];
}

- (void)deployDeceleratorDonut {
  DeceleratorDonut *donut = [[DeceleratorDonut alloc] init];
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [self addChild:donut];
  [self randomlyPositionDonut:donut];
  [self expandAndContractDonut:donut];
}

- (void)deployBlackholeDonut {
  BlackholeDonut *donut = [[BlackholeDonut alloc] init];
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [self addChild:donut];
  [self randomlyPositionDonut:donut];
  [self expandAndContractDonut:donut];
}

- (void)deployBouncingDonut {
  BouncingDonut *donut = [[BouncingDonut alloc] init];
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

  Catapult *catapult = [[Catapult alloc] init];
  donut.catapult = catapult;

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
    CGFloat f = t - 1;
    return 1 + f * f * f;
  };
  SKAction *scaleDown = [SKAction scaleTo:0 duration:donut.contractDuration];

  NSArray *actions = @[scaleUp, scaleDown, [SKAction removeFromParent]];
  SKAction *sequence = [SKAction sequence:actions];
  [donut runAction:sequence withKey:kExpandAndContractActionKey];
}

- (void)slowDownDonut:(SKSpriteNode<Donut> *)donut {
  [donut actionForKey:kExpandAndContractActionKey].speed = 0.4;
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
