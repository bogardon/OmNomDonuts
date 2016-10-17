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
#import "ScoreCounterNode.h"
#import "ViewController.h"

static const uint32_t kStaticCategory = 0x1 << 0;
static const uint32_t kMovingCategory = 0x1 << 1;
static const uint32_t kEdgeCategory = 0x1 << 2;
static NSString *const kExpandAndContractActionKey = @"kExpandAndContractActionKey";
static NSString *const kResetContractSpeedKey = @"kResetContractSpeedKey";
static NSString *const kScheduleNextDeployKey = @"kScheduleNextDeployKey";
static const CGFloat kPadding = 4.0;

@interface GameScene ()<DonutDelegate, SKPhysicsContactDelegate>
@end

@implementation GameScene {
  ScoreCounterNode *_scoreCounter;
  LifeCounterNode *_lifeCounter;
  GameConfig *_gameConfig;

  BouncingDonut *_activeBouncingDonut;

  BOOL _gameOver;

  SKAction *_woopUpAction;
  SKAction *_woopDownAction;

  SKNode *_backgroundLayer;
  SKNode *_gameLayer;
  SKNode *_menuLayer;

  NSInteger _scorePerLevel;
}

- (instancetype)initWithSize:(CGSize)size {
  self = [super initWithSize:size];
  if (self) {
    _scorePerLevel = 100;

    _gameConfig = [GameConfig sharedConfig];

    _woopUpAction = [SKAction playSoundFileNamed:@"woop_up_converted.caf" waitForCompletion:YES];
    _woopDownAction = [SKAction playSoundFileNamed:@"woop_down_converted.caf"
                                 waitForCompletion:YES];

    self.backgroundColor =
        [SKColor colorWithRed:204.0 / 255.0 green:234.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.restitution = 1;
    self.physicsBody.friction = 0;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsBody.categoryBitMask = kEdgeCategory;
    self.physicsWorld.contactDelegate = self;
  }
  return self;
}

- (void)didMoveToView:(SKView *)view {
  [super didMoveToView:view];

  [self createContent];
  [self startGame];
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
  for (Donut *donut in [_gameLayer.children reverseObjectEnumerator]) {
    if (![donut isKindOfClass:[Donut class]]) {
      continue;
    }
    if (donut.state != kDonutStatePending) {
      continue;
    }
    CGFloat distanceToCenter = hypot(point.x - donut.position.x, point.y - donut.position.y);
    if (distanceToCenter <= MAX(donut.size.width / 2, _gameConfig.forgivenessRadius)) {
      [self hitDonut:donut point:point];
      return;
    }
  }

  [self showMissAtPoint:point];
}

#pragma mark SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
  Donut *donut = (Donut *)
      (contact.bodyA.categoryBitMask == kMovingCategory ? contact.bodyB.node : contact.bodyA.node);
  [self hitDonut:donut point:contact.contactPoint];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
}

#pragma mark DonutDelegate

- (void)donutWillTransitionState:(Donut *)donut
                        oldState:(DonutState)oldState
                        newState:(DonutState)newState {
  switch (newState) {
    case kDonutStatePending:
      [self runAction:_woopUpAction];
      break;
    case kDonutStateTapped:
      if ([donut isKindOfClass:[RegularDonut class]]) {
        [self deployRegularDonut];
        NSInteger oldMultiple = _scoreCounter.score / _scorePerLevel;
        _scoreCounter.score += 10;
        NSInteger newMultiple = _scoreCounter.score / _scorePerLevel;
        if (newMultiple > oldMultiple &&
            _gameConfig.finalNumberOfDonuts > _gameConfig.initialNumberOfDonuts + newMultiple) {
          [self deployRegularDonut];
        }
      }
      break;
    case kDonutStateMissed:
      if ([donut isKindOfClass:[RegularDonut class]]) {
        [self deployRegularDonut];
        [_lifeCounter decrementLives];
        if (_lifeCounter.currentLives == 0) {
          _gameOver = YES;
          self.paused = YES;
          [self presentPostGameNodes];
        }
      }
      break;
    default:
      break;
  }
}

#pragma mark Private Methods

- (void)hitDonut:(Donut *)donut point:(CGPoint)point {
  [donut runFinishActions];
}

- (void)startGame {
  [_scoreCounter reset];
  [_lifeCounter reset];
  for (NSInteger i = 0; i < _gameConfig.initialNumberOfDonuts; i++) {
    [self deployRegularDonut];
  }
}

- (void)endGame {
  _gameOver = YES;
  self.paused = YES;
}

- (void)deployRegularDonut {
  RegularDonut *donut = [[RegularDonut alloc] init];
  donut.delegate = self;
  donut.size = CGSizeMake(2 * _gameConfig.donutRadius, 2 * _gameConfig.donutRadius);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [_gameLayer insertChild:donut atIndex:0];
  [self randomlyPositionDonut:donut];
  [donut runDeployActions];
}

- (void)deployDeceleratorDonut {
  DeceleratorDonut *donut = [[DeceleratorDonut alloc] init];
  donut.delegate = self;
  donut.size = CGSizeMake(2 * _gameConfig.donutRadius, 2 * _gameConfig.donutRadius);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [_gameLayer insertChild:donut atIndex:0];
  [self randomlyPositionDonut:donut];
  [donut runDeployActions];
}

- (void)deployBlackholeDonut {
  BlackholeDonut *donut = [[BlackholeDonut alloc] init];
  donut.delegate = self;
  donut.size = CGSizeMake(2 * _gameConfig.donutRadius, 2 * _gameConfig.donutRadius);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.collisionBitMask = 0;
  donut.physicsBody.categoryBitMask = kStaticCategory;
  [_gameLayer insertChild:donut atIndex:0];
  [self randomlyPositionDonut:donut];
  [donut runDeployActions];
}

- (void)deployBouncingDonut {
  BouncingDonut *donut = [[BouncingDonut alloc] init];
  donut.delegate = self;
  donut.size = CGSizeMake(2 * _gameConfig.donutRadius, 2 * _gameConfig.donutRadius);
  donut.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:donut.size.width / 2];
  donut.physicsBody.categoryBitMask = kMovingCategory;
  donut.physicsBody.collisionBitMask = kEdgeCategory;
  donut.physicsBody.mass = 0;
  donut.physicsBody.linearDamping = 0;
  donut.physicsBody.angularDamping = 0;
  donut.physicsBody.restitution = 1;
  donut.physicsBody.friction = 0;
  [_gameLayer insertChild:donut atIndex:0];
  [self randomlyPositionDonut:donut];
  [donut runDeployActions];
}

- (void)randomlyPositionDonut:(Donut *)donut {
  CGFloat halfDimension = donut.size.width / 2.0;
  CGPoint position =
      CGPointMake(halfDimension + arc4random_uniform(self.size.width - 2 * halfDimension),
                  halfDimension + arc4random_uniform(self.size.height - 2 * halfDimension));
  donut.position = position;
}

- (void)presentPostGameNodes {
  PlayNode *play = [[PlayNode alloc] init];
  play.position = CGPointMake(CGRectGetMidX(self.frame) - play.size.width,
                              CGRectGetMidY(self.frame));
  play.userInteractionEnabled = YES;
  [play addTarget:self selector:@selector(restartGame)];
  [_menuLayer addChild:play];

  MenuNode *menu = [[MenuNode alloc] init];
  menu.position = CGPointMake(CGRectGetMidX(self.frame) + menu.size.width,
                              CGRectGetMidY(self.frame));
  menu.userInteractionEnabled = YES;
  [menu addTarget:self selector:@selector(showMainMenu)];
  [_menuLayer addChild:menu];
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
  _backgroundLayer = [SKNode node];
  _gameLayer = [SKNode node];
  _menuLayer = [SKNode node];
  [self addChild:_backgroundLayer];
  [self addChild:_gameLayer];
  [self addChild:_menuLayer];

  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  CGFloat targetWidth = self.size.width;

  for (int i = 1; i <= 4; i++) {
    NSString *textureName = [NSString stringWithFormat:@"cloud%d", i];
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:textureName]];
    CGFloat ratio = cloud.size.width / cloud.size.height;
    if (targetWidth < cloud.size.width) {
      cloud.size = CGSizeMake(targetWidth, targetWidth / ratio);
    }
    CGFloat xOffset = arc4random_uniform(100);
    xOffset = arc4random_uniform(2) ? xOffset : -xOffset;
    CGFloat positionY = (i - 1) * self.size.height / 4;
    cloud.position = CGPointMake(self.frame.size.width / 2 + xOffset,
                                 positionY + cloud.frame.size.height / 2);
    [_backgroundLayer addChild:cloud];
  }

  _scoreCounter = [ScoreCounterNode labelNodeWithFontNamed:@"HelveticaNeue"];
  _scoreCounter.fontColor = [SKColor darkTextColor];
  _scoreCounter.fontSize = 20;
  _scoreCounter.position =
      CGPointMake(CGRectGetMinX(self.frame) + kPadding, CGRectGetMaxY(self.frame) - kPadding);
  _scoreCounter.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  _scoreCounter.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [_menuLayer addChild:_scoreCounter];

  _lifeCounter = [[LifeCounterNode alloc] initWithMaxLives:_gameConfig.maxLives];
  CGRect accumulatedFrame = [_lifeCounter calculateAccumulatedFrame];
  _lifeCounter.position =
      CGPointMake(CGRectGetMidX(self.frame) - accumulatedFrame.size.width / 2,
                  CGRectGetMaxY(self.frame) - accumulatedFrame.size.height / 2 - kPadding);
  [_menuLayer addChild:_lifeCounter];
}

- (void)showMissAtPoint:(CGPoint)point {
  MissNode *shape = [MissNode node];
  shape.position = point;
  [shape showAndHide];
  [_gameLayer addChild:shape];

  [self runAction:_woopDownAction];
}

@end
