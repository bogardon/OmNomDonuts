#import "GameScene.h"

#import <math.h>

#import "BlackholeDonut.h"
#import "BouncingDonut.h"
#import "DeceleratorDonut.h"
#import "GameConfig.h"
#import "LifeCounterNode.h"
#import "MainMenuScene.h"
#import "MenuNode.h"
#import "MissNode.h"
#import "RegularDonut.h"
#import "PlayNode.h"
#import "SKNode+Control.h"
#import "SKNode+Utils.h"
#import "ScoreCounterNode.h"
#import "ViewController.h"

static const uint32_t kStaticCategory = 0x1 << 0;
static const uint32_t kMovingCategory = 0x1 << 1;
static const uint32_t kEdgeCategory = 0x1 << 2;
static NSString *const kExpandAndContractActionKey = @"kExpandAndContractActionKey";
static NSString *const kResetContractSpeedKey = @"kResetContractSpeedKey";
static NSString *const kScheduleNextDeployKey = @"kScheduleNextDeployKey";
static const CGFloat kPadding = 4.0;

@interface GameScene ()<SKPhysicsContactDelegate>
@end

@implementation GameScene {
  ScoreCounterNode *_scoreCounter;
  LifeCounterNode *_lifeCounter;
  GameConfig *_gameConfig;

  BouncingDonut *_activeBouncingDonut;

  BOOL _gameOver;
}

- (instancetype)initWithSize:(CGSize)size {
  self = [super initWithSize:size];
  if (self) {
    _gameConfig = [GameConfig sharedConfig];

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

  if (self.view.paused || _gameOver) {
    return;
  }

  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInNode:self];
  for (SKSpriteNode<DonutProtocol> *donut in [self.pendingDonuts reverseObjectEnumerator]) {
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
  SKSpriteNode<DonutProtocol> *donut = (SKSpriteNode<DonutProtocol> *)
      (contact.bodyA.categoryBitMask == kMovingCategory ? contact.bodyB.node : contact.bodyA.node);
  [self hitDonut:donut point:contact.contactPoint];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
}

#pragma mark Private Methods

- (void)hitDonut:(SKSpriteNode<DonutProtocol> *)donut point:(CGPoint)point {
  donut.hit = YES;
  _scoreCounter.score += donut.value;

  if ([donut isKindOfClass:[RegularDonut class]]) {
    [self fadeOutDonut:donut];
  } else if ([donut isKindOfClass:[DeceleratorDonut class]]) {
    [self fadeOutDonut:donut];
    CGFloat gameSpeed = 0.5;
    _gameConfig.gameSpeed = gameSpeed;
    for (SKSpriteNode<DonutProtocol> *otherDonut in self.pendingDonuts) {
      [otherDonut actionForKey:kExpandAndContractActionKey].speed = _gameConfig.gameSpeed;
    }
    [self actionForKey:kScheduleNextDeployKey].speed = _gameConfig.gameSpeed;
    SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:5.0],
                                              [SKAction runBlock:^{
      _gameConfig.gameSpeed = 1.0;
    }]]];
    [self removeActionForKey:kResetContractSpeedKey];
    [self runAction:sequence withKey:kResetContractSpeedKey];
  } else if ([donut isKindOfClass:[BlackholeDonut class]]) {
    [self fadeOutDonut:donut];
    for (SKSpriteNode<DonutProtocol> *otherDonut in self.pendingDonuts) {
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

- (void)startGame {
  [self scheduleNextDeploy];
}

- (void)endGame {
  _gameOver = YES;
  for (SKNode *node in self.allDonuts) {
    [node removeAllActions];
  }
  [self removeAllActions];
}

- (void)scheduleNextDeploy {
  SKAction *wait = [SKAction waitForDuration:_gameConfig.deployPeriod];
  SKAction *deploy = [SKAction performSelector:@selector(onDeployTimer) onTarget:self];
  __weak GameScene *weakSelf = self;
  SKAction *reschedule = [SKAction runBlock:^{
    [weakSelf scheduleNextDeploy];
  }];
  SKAction *sequence = [SKAction sequence:@[deploy, wait, reschedule]];
  sequence.speed = _gameConfig.gameSpeed;
  [self runAction:sequence];
}

- (void)onDeployTimer {
  for (NSInteger i = 0; i < _gameConfig.donutsPerDeploy; i++) {
    [self runAction:[SKAction waitForDuration:1.5 withRange:3.0]
         completion:^{
           if (self->_gameOver) {
             return;
           }
           [self deployRegularDonut];
         }];
  }

  if (arc4random_uniform(4) == 0) {
    [self deployDeceleratorDonut];
  } else if (arc4random_uniform(4) == 0) {
    [self deployBlackholeDonut];
  } else if (arc4random_uniform(4) == 0) {
    [self deployBouncingDonut];
  }
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

- (void)randomlyPositionDonut:(SKSpriteNode<DonutProtocol> *)donut {
  CGFloat halfDimension = donut.size.width / 2.0;
  CGPoint position =
      CGPointMake(halfDimension + arc4random() % (int)(self.size.width - 2 * halfDimension),
                  halfDimension + arc4random() % (int)(self.size.height - 2 * halfDimension));
  donut.position = position;
}

- (void)expandAndContractDonut:(SKSpriteNode<DonutProtocol> *)donut {
  [donut setScale:0];

  SKAction *scaleUp = [SKAction scaleTo:1 duration:0.25];
  scaleUp.timingFunction = ^float(float t) {
    CGFloat f = t - 1.0;
    return 1.0 - f * f * f * f;
  };
  SKAction *wait = [SKAction waitForDuration:0.1];
  SKAction *scaleDown = [SKAction scaleTo:0 duration:donut.contractDuration];

  __weak SKSpriteNode<DonutProtocol> *weakDonut = donut;
  __weak GameScene *weakSelf = self;
  SKAction *miss = [SKAction runBlock:^{
    [weakSelf missDonut:weakDonut];
  }];

  NSArray *actions = @[scaleUp, wait, scaleDown, [SKAction removeFromParent], miss];
  SKAction *sequence = [SKAction sequence:actions];
  sequence.speed = _gameConfig.gameSpeed;
  [donut runAction:sequence withKey:kExpandAndContractActionKey];

  [self runAction:[SKAction playSoundFileNamed:@"woop_up.caf" waitForCompletion:YES]];
}

- (void)fadeOutDonut:(SKSpriteNode<DonutProtocol> *)donut {
  [donut removeAllActions];
  NSArray *actions = @[[SKAction fadeOutWithDuration:0.2], [SKAction removeFromParent]];
  SKAction *sequence = [SKAction sequence:actions];
  [donut runAction:sequence];
}

- (void)gravitateDonut:(SKSpriteNode<DonutProtocol> *)donut towardsPoint:(CGPoint)point {
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

- (void)missDonut:(SKSpriteNode<DonutProtocol> *)donut {
  if ([donut isKindOfClass:[RegularDonut class]]) {
    [_lifeCounter decrementLives];

    if (_lifeCounter.currentLives == 0) {
      [self endGame];
      [self presentPostGameNodes];
    }
  }
}

- (void)presentPostGameNodes {
  PlayNode *play = [[PlayNode alloc] init];
  play.position = CGPointMake(CGRectGetMidX(self.frame) - play.size.width,
                              CGRectGetMidY(self.frame));
  play.userInteractionEnabled = YES;
  [play addTarget:self selector:@selector(restartGame)];
  [self addChild:play];

  MenuNode *menu = [[MenuNode alloc] init];
  menu.position = CGPointMake(CGRectGetMidX(self.frame) + menu.size.width,
                              CGRectGetMidY(self.frame));
  menu.userInteractionEnabled = YES;
  [menu addTarget:self selector:@selector(showMainMenu)];
  [self addChild:menu];
}

- (void)showMainMenu {
  MainMenuScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.view.bounds.size];
  mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition crossFadeWithDuration:0.5];
  [self.view presentScene:mainMenuScene transition:transition];
}

- (void)restartGame {
  GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
  gameScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition crossFadeWithDuration:0.5];
  [self.view presentScene:gameScene transition:transition];
}

- (void)createContent {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  CGFloat lastY = 0;
  CGFloat targetWidth = 320;
  for (int i = 1; i <= 4; i++) {
    NSString *textureName = [NSString stringWithFormat:@"cloud%d", i];
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:textureName]];
    CGFloat ratio = cloud.size.width / cloud.size.height;
    if (targetWidth < cloud.size.width) {
      cloud.size = CGSizeMake(targetWidth, targetWidth / ratio);
    }
    CGFloat xOffset = (CGFloat)(arc4random() % 100);
    xOffset = arc4random() % 2 ? xOffset : -xOffset;
    cloud.position = CGPointMake(self.frame.size.width / 2 + xOffset,
                                 lastY + cloud.frame.size.height / 2);
    [self addChild:cloud];
    lastY = CGRectGetMaxY(cloud.frame);
  }

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
}

- (void)showMissAtPoint:(CGPoint)point {
  MissNode *shape = [MissNode node];
  shape.position = point;
  [shape showAndHide];
  [self addChild:shape];

  [self runAction:[SKAction playSoundFileNamed:@"woop_down.caf" waitForCompletion:YES]];
}

@end
