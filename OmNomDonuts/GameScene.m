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
#import "ViewController.h"

static const CFTimeInterval kSlowestDeployPeriod = 1.2;
static const CFTimeInterval kFastestDeployPeriod = 0.3;
static const CFTimeInterval kExponentialDecayLambda = 1.0 / 100.0;
static const NSInteger kMaxLives = 5;

@interface GameScene ()

@property(nonatomic, assign) NSInteger numberOfMisses;
@property(nonatomic, assign) NSInteger score;
@property(nonatomic, assign, getter=isContentCreated) BOOL contentCreated;
@property(nonatomic, assign) CFTimeInterval gameStartTime;

@end

@implementation GameScene {
  SKLabelNode *_scoreLabel;
  LifeCounterNode *_lifeCounter;
  SKShapeNode *_pauseNode;

  CFTimeInterval _lastCurrentTime;
  CFTimeInterval _elapsedGameTime;
  CFTimeInterval _lastDeployTime;

  GameplayEffect _effects;
}

- (instancetype)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
  }
  return self;
}

#pragma mark - SKScene

- (void)didMoveToView:(SKView *)view {
  if (!self.isContentCreated) {
    self.contentCreated = YES;
    [self createContent];
    [self resetGame];
  }
}

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

#pragma mark - Private

- (void)resetGame {
  self.gameStartTime = 0;
  self.score = 0;
  self.numberOfMisses = 0;
  _scoreLabel.text = @"0";
  _lifeCounter.lives = kMaxLives;

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

  CGFloat alpha = pause ? 0.3 : 1;

  _lifeCounter.alpha = alpha;
  _scoreLabel.alpha = alpha;
  _pauseNode.alpha = alpha;
  [self enumerateChildNodesWithName:@"donut"
                         usingBlock:^(SKNode *node, BOOL *stop) {
                           node.alpha = alpha;
                         }];
  [self enumerateChildNodesWithName:@"error"
                         usingBlock:^(SKNode *node, BOOL *stop) {
                           node.alpha = alpha;
                         }];
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

  _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
  _scoreLabel.name = @"score";
  _scoreLabel.fontColor = [SKColor darkTextColor];
  _scoreLabel.fontSize = 20;
  _scoreLabel.position = CGPointMake(CGRectGetMinX(self.frame) + 5, CGRectGetMaxY(self.frame) - 5);
  _scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [self addChild:_scoreLabel];

  _lifeCounter = [[LifeCounterNode alloc] initWithMaxLives:kMaxLives];
  CGRect accumulatedFrame = [_lifeCounter calculateAccumulatedFrame];
  _lifeCounter.position =
      CGPointMake(CGRectGetMidX(self.frame) - accumulatedFrame.size.width / 2,
                  CGRectGetMaxY(self.frame) - accumulatedFrame.size.height / 2 - 5);
  [self addChild:_lifeCounter];

  _pauseNode = [[SKShapeNode alloc] init];
  _pauseNode.lineWidth = 0;
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:CGPointZero];
  [path addLineToPoint:CGPointMake(0, 16)];
  [path addLineToPoint:CGPointMake(4, 16)];
  [path addLineToPoint:CGPointMake(4, 0)];
  [path closePath];
  [path moveToPoint:CGPointMake(8, 0)];
  [path addLineToPoint:CGPointMake(8, 16)];
  [path addLineToPoint:CGPointMake(12, 16)];
  [path addLineToPoint:CGPointMake(12, 0)];
  [path closePath];
  _pauseNode.fillColor = [UIColor colorWithWhite:0 alpha:0.75f];
  _pauseNode.path = path.CGPath;
  _pauseNode.name = @"pause";
  accumulatedFrame = [_pauseNode calculateAccumulatedFrame];
  _pauseNode.position = CGPointMake(CGRectGetMaxX(self.frame) - accumulatedFrame.size.width - 5,
                                    CGRectGetMaxY(self.frame) - accumulatedFrame.size.height - 5);
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

  [self modifyScoreWithDifference:10];
}

- (void)missDonut:(Donut *)donut {
  self.numberOfMisses++;

  [self showErrorAtPoint:donut.position];

  _lifeCounter.lives--;

  if (self.numberOfMisses == 5) {
    [self loseGame];
  }
}

- (void)slowDonutsForInterval:(CFTimeInterval)interval {
  [self enumerateChildNodesWithName:@"donut"
                         usingBlock:^(SKNode *node, BOOL *stop) {
                           node.speed = 0.5;
                         }];
}

- (void)showErrorAtPoint:(CGPoint)point {
  SKShapeNode *shape = [SKShapeNode node];
  shape.name = @"error";
  shape.path =
      [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-5, -5, 10, 10) cornerRadius:5].CGPath;
  shape.fillColor = shape.strokeColor = [SKColor redColor];
  shape.position = point;

  NSArray *actions = @[ [SKAction fadeOutWithDuration:0.2], [SKAction removeFromParent] ];
  SKAction *sequence = [SKAction sequence:actions];
  [shape runAction:sequence];

  [self addChild:shape];
}

- (void)modifyScoreWithDifference:(NSInteger)difference {
  self.score = MAX(0, self.score + difference);

  NSInteger displayedScore = [_scoreLabel.text integerValue];

  if (displayedScore <= 0 && difference < 0) {
    return;
  }

  NSArray *actions = @[
    [SKAction runBlock:^{
      NSInteger difference = self.score - displayedScore;
      NSInteger step = difference / ABS(difference);
      NSString *text = [@([_scoreLabel.text integerValue] + step) description];
      _scoreLabel.text = text;
    }],
    [SKAction waitForDuration:0.05]
  ];
  SKAction *sequence = [SKAction sequence:actions];

  [_scoreLabel removeAllActions];
  [_scoreLabel runAction:[SKAction repeatAction:sequence count:ABS(self.score - displayedScore)]];
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.paused) {
    [self pauseGame:NO];
  } else {
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
      CGPoint point = [touch locationInNode:self];
      SKNode *node = [self nodeAtPoint:point];
      if ([node.name isEqualToString:@"donut"]) {
        Donut *donut = (Donut *)node;
        if (!donut.isHit) {
          donut.hit = YES;
          [self hitDonut:donut];
        }
      } else if ([node.name isEqualToString:@"pause"]) {
        [self pauseGame:YES];
      } else {
        [self modifyScoreWithDifference:-5];
        [self showErrorAtPoint:point];
      }
    }];
  }
}

@end
