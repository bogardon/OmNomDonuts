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

static const CFTimeInterval kSlowestDeployPeriod = 1.2;
static const CFTimeInterval kFastestDeployPeriod = 0.3;
static const CFTimeInterval kExponentialDecayLambda = 1.0/100.0;

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
@property (nonatomic, strong) SKLabelNode *numberOfMissesLabel;

@property (nonatomic, assign, getter=isContentCreated) BOOL contentCreated;

@property (nonatomic, assign) CFTimeInterval deployPeriod;
@property (nonatomic, assign) CFTimeInterval lastDeployTime;

@property (nonatomic, assign) CFTimeInterval gameStartTime;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.donutFactory = [[DonutFactory alloc] init];
    }
    return self;
}

#pragma mark - SKScene

- (void)didMoveToView:(SKView *)view
{
    if (!self.isContentCreated) {
        self.contentCreated = YES;
        [self createContent];
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */

    if (self.gameStartTime == 0)
        self.gameStartTime = currentTime;

    CFTimeInterval elapsed = currentTime - self.gameStartTime;
    self.deployPeriod = MAX(kFastestDeployPeriod, kSlowestDeployPeriod*exp(-elapsed*kExponentialDecayLambda));

    [self deployDonutWithUpdate:currentTime];
}

#pragma mark - Public

- (void)resetGame
{
    self.gameStartTime = 0;
    self.score = 0;
    self.numberOfMisses = 0;
    self.numberOfMissesLabel.text = nil;
    self.scoreLabel.text = @"0";

    NSMutableArray *donuts = [NSMutableArray array];
    [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:Donut.class]) {
            [donuts addObject:obj];
        }
    }];
    [self removeChildrenInArray:donuts];
}

#pragma mark - Private

- (void)createContent
{
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    background.anchorPoint = CGPointMake(0, 0);
    [self addChild:background];

    SKSpriteNode *recordPlayer = [SKSpriteNode spriteNodeWithImageNamed:@"record_player"];
    recordPlayer.anchorPoint = CGPointMake(0, 0);
    [self addChild:recordPlayer];

    SKLabelNode *numberOfMissesLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    numberOfMissesLabel.name = @"misses";
    numberOfMissesLabel.fontColor = [SKColor redColor];
    numberOfMissesLabel.fontSize = 30;
    numberOfMissesLabel.position = CGPointMake(CGRectGetMaxX(self.frame),CGRectGetMaxY(self.frame));
    numberOfMissesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    numberOfMissesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    [self addChild:numberOfMissesLabel];

    self.numberOfMissesLabel = numberOfMissesLabel;

    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    scoreLabel.name = @"score";
    scoreLabel.fontColor = [SKColor darkTextColor];
    scoreLabel.fontSize = 30;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame));
    scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    [self addChild:scoreLabel];

    self.scoreLabel = scoreLabel;
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

- (void)deployDonutAfterDelay:(CFTimeInterval)delay
{
    Donut *donut = [self.donutFactory getDonutWithSize:CGSizeMake(64, 64)];
    [self addChild:donut];
    CGPoint point = CGPointMake(arc4random()%(int)self.size.width, arc4random()%(int)self.size.height);

    SKAction *wait = [SKAction waitForDuration:delay];

    SKAction *move = [SKAction moveTo:point duration:0.2];
    move.timingMode = SKActionTimingEaseOut;
    [donut setScale:0.1];

    SKAction *scaleUp = [SKAction scaleTo:1 duration:1.2];
    scaleUp.timingMode = SKActionTimingEaseOut;

    SKAction *scaleDown = [SKAction scaleTo:0 duration:1.2];
    scaleDown.timingMode = SKActionTimingEaseIn;

    NSArray *actions = @[
                         wait,
                         move,
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

- (void)missDonut:(Donut *)donut
{
    self.numberOfMisses++;
    [self showErrorAtPoint:donut.position];
}

- (void)showErrorAtPoint:(CGPoint)point
{
    SKShapeNode *shape = [SKShapeNode node];
    shape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-5, -5, 10, 10) cornerRadius:5].CGPath;
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

- (void)modifyScoreWithDifference:(NSInteger)difference
{
    self.score += difference;

    NSInteger displayedScore = [self.scoreLabel.text integerValue];

    NSArray *actions = @[
                          [SKAction runBlock:^{
                              if (self.score - displayedScore > 0) {
                                  self.scoreLabel.text = [@([self.scoreLabel.text integerValue] + 1) description];
                              } else {
                                  self.scoreLabel.text = [@([self.scoreLabel.text integerValue] - 1) description];
                              }
                          }],
                          [SKAction waitForDuration:0.05]
                          ];
    SKAction *sequence = [SKAction sequence:actions];

    [self.scoreLabel removeAllActions];
    [self.scoreLabel runAction:[SKAction repeatAction:sequence count:ABS(self.score - displayedScore)]];
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
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

}

@end
