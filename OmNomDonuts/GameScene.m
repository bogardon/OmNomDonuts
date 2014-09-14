//
//  GameScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//
//

#import "GameScene.h"
#import "MainMenuScene.h"
#import "DonutFactory.h"
#import "Donut.h"
#import <math.h>
#import "ViewController.h"
#import "LifeCounterNode.h"

static const CFTimeInterval kSlowestDeployPeriod = 1.2;
static const CFTimeInterval kFastestDeployPeriod = 0.3;
static const CFTimeInterval kExponentialDecayLambda = 1.0/100.0;
static const NSInteger kMaxLives = 5;

@interface GameScene ()

@property (nonatomic, strong) DonutFactory *donutFactory;

- (void)createContent;

- (void)deployDonutWithUpdate:(CFTimeInterval)currentTime;
- (void)deployDonutAfterDelay:(CFTimeInterval)delay;

- (void)hitDonut:(Donut *)donut;
- (void)missDonut:(Donut *)donut;

- (void)showErrorAtPoint:(CGPoint)point;

- (void)modifyScoreWithDifference:(NSInteger)difference;

@property (nonatomic, assign) NSInteger numberOfMisses;

@property (nonatomic, assign) NSInteger score;

@property (nonatomic, strong) SKLabelNode *scoreLabel;

@property (nonatomic, assign, getter=isContentCreated) BOOL contentCreated;

@property (nonatomic, assign) CFTimeInterval deployPeriod;
@property (nonatomic, assign) CFTimeInterval lastDeployTime;

@property (nonatomic, assign) CFTimeInterval gameStartTime;

@end

@implementation GameScene {
  LifeCounterNode *_lifeCounter;
}

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
      /* Setup your scene here */
      self.donutFactory = [[DonutFactory alloc] init];
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
  /* Called before each frame is rendered */
  if (self.state != GameStatePlaying) {
    return;
  }

  if (self.gameStartTime == 0)
    self.gameStartTime = currentTime;

  CFTimeInterval elapsed = currentTime - self.gameStartTime;
  self.deployPeriod = MAX(kFastestDeployPeriod, kSlowestDeployPeriod*exp(-elapsed*kExponentialDecayLambda));

  [self deployDonutWithUpdate:currentTime];
}

#pragma mark - Public

- (void)resetGame {
  self.gameStartTime = 0;
  self.score = 0;
  self.numberOfMisses = 0;
  self.scoreLabel.text = @"0";
  _lifeCounter.lives = kMaxLives;

  NSMutableArray *donuts = [NSMutableArray array];
  [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isKindOfClass:Donut.class]) {
      [donuts addObject:obj];
    }
  }];
  [self removeChildrenInArray:donuts];
}

- (void)playGame
{
    self.state = GameStatePlaying;
    [self resetGame];
}

- (void)resumeGame
{
    self.state = GameStatePlaying;
    self.paused = NO;
}

- (void)pauseGame
{
    self.state = GameStatePaused;
    self.paused = YES;
}

- (void)loseGame {
  self.state = GameStateLost;
  [self enumerateChildNodesWithName:@"donut" usingBlock:^(SKNode *node, BOOL *stop) {
    [node removeAllActions];
  }];

  MainMenuScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.view.bounds.size];
  mainMenuScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition flipVerticalWithDuration:0.5f];
  [self.view presentScene:mainMenuScene transition:transition];
}

#pragma mark - Private

- (void)createContent {
  SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
  background.anchorPoint = CGPointMake(0, 0);
  [self addChild:background];

  SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
  scoreLabel.name = @"score";
  scoreLabel.fontColor = [SKColor darkTextColor];
  scoreLabel.fontSize = 20;
  scoreLabel.position = CGPointMake(CGRectGetMinX(self.frame) + 5,CGRectGetMaxY(self.frame) - 5);
  scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  [self addChild:scoreLabel];

  self.scoreLabel = scoreLabel;

  _lifeCounter = [[LifeCounterNode alloc] initWithMaxLives:kMaxLives];
  CGRect accumulatedFrame = [_lifeCounter calculateAccumulatedFrame];
  _lifeCounter.position = CGPointMake(CGRectGetMaxX(self.frame) - accumulatedFrame.size.width - 5,
                                      CGRectGetMaxY(self.frame) - accumulatedFrame.size.height/2 - 5);
  [self addChild:_lifeCounter];
}

- (void)deployDonutWithUpdate:(CFTimeInterval)currentTime
{
    if (currentTime - self.lastDeployTime < self.deployPeriod) {
        return;
    }

    [self deployDonutAfterDelay:0];

    if (arc4random() % 5 == 0)
        [self deployDonutAfterDelay:0.3];

    self.lastDeployTime = currentTime;
}

- (void)deployDonutAfterDelay:(CFTimeInterval)delay {
  Donut *donut = [self.donutFactory getDonutWithSize:CGSizeMake(64, 64)];
  donut.name = @"donut";

  CGPoint position = CGPointMake(arc4random()%(int)self.size.width, arc4random()%(int)self.size.height);
  donut.position = position;
  [donut setScale:0.1];
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

- (void)hitDonut:(Donut *)donut
{
    [donut removeAllActions];

    NSArray *actions = @[
                         [SKAction fadeOutWithDuration:0.2],
                         [SKAction removeFromParent]
                         ];
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

- (void)showErrorAtPoint:(CGPoint)point {
  SKShapeNode *shape = [SKShapeNode node];
  shape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-5, -5, 10, 10)
                                          cornerRadius:5].CGPath;
  shape.fillColor = shape.strokeColor = [SKColor redColor];
  shape.position = point;

  NSArray *actions = @[
                       [SKAction fadeOutWithDuration:0.2],
                       [SKAction removeFromParent]
                       ];
  SKAction *sequence = [SKAction sequence:actions];
  [shape runAction:sequence];

  [self addChild:shape];
}

- (void)modifyScoreWithDifference:(NSInteger)difference {
  self.score = MAX(0, self.score + difference);

  NSInteger displayedScore = [self.scoreLabel.text integerValue];

  if (displayedScore <= 0 && difference < 0) {
    return;
  }

  NSArray *actions = @[
                       [SKAction runBlock:^{
                         NSInteger difference = self.score - displayedScore;
                         NSInteger step = difference/ABS(difference);
                         NSString *text = [@([self.scoreLabel.text integerValue] + step) description];
                         self.scoreLabel.text = text;
                        }],
                        [SKAction waitForDuration:0.05]
                        ];
  SKAction *sequence = [SKAction sequence:actions];

  [self.scoreLabel removeAllActions];
  [self.scoreLabel runAction:[SKAction repeatAction:sequence
                                              count:ABS(self.score - displayedScore)]];
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == GameStatePlaying) {
        [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
            CGPoint point = [touch locationInNode:self];

            SKNode *node = [self nodeAtPoint:point];
            if ([node isKindOfClass:Donut.class]) {
                Donut *donut = (Donut *)node;
                if (!donut.isHit) {
                    donut.hit = YES;
                    [self hitDonut:donut];
                }
            } else {
                [self modifyScoreWithDifference:-5];
                [self showErrorAtPoint:point];
            }
        }];
    } else if (self.state == GameStateLost) {
        [self playGame];
    }
}

@end
