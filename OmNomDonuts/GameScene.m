//
//  GameScene.m
//  OmNomDonuts
//
//  Created by John Z Wu on 4/27/14.
//
//

#import "GameScene.h"
#import "MyScene.h"
#import "DonutFactory.h"
#import "Donut.h"
#import <math.h>

static const CFTimeInterval kSlowestDeployPeriod = 1.2;
static const CFTimeInterval kFastestDeployPeriod = 0.3;
static const CFTimeInterval kExponentialDecayLambda = 1.0/100.0;

@interface GameScene ()

@property (nonatomic, strong) DonutFactory *donutFactory;

- (void)deployDonutAfterDeplay:(CFTimeInterval)delay;
- (void)hitDonut:(Donut *)donut;

- (void)onErrorAtPoint:(CGPoint)point;

- (void)createContent;
- (void)onDonutWillDisappear:(Donut *)donut;

- (void)deployDonutWithUpdate:(CFTimeInterval)currentTime;

@property (nonatomic, assign) NSUInteger numberOfMisses;
@property (nonatomic, assign) NSUInteger numberOfHits;

@property (nonatomic, strong) SKLabelNode *numberOfMissesLabel;
@property (nonatomic, strong) SKLabelNode *numberOfHitsLabel;

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

#pragma mark - Private

- (void)createContent
{
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    background.anchorPoint = CGPointMake(0, 0);
    [self addChild:background];

    SKLabelNode *numberOfMissesLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    numberOfMissesLabel.name = @"misses";
    numberOfMissesLabel.text = @"0";
    numberOfMissesLabel.fontColor = [SKColor redColor];
    numberOfMissesLabel.fontSize = 30;
    numberOfMissesLabel.position = CGPointMake(CGRectGetMidX(self.frame),0);
    numberOfMissesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    [self addChild:numberOfMissesLabel];

    self.numberOfMissesLabel = numberOfMissesLabel;

    SKLabelNode *numberOfHitsLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    numberOfHitsLabel.name = @"hits";
    numberOfHitsLabel.text = @"0";
    numberOfHitsLabel.fontColor = [SKColor greenColor];
    numberOfHitsLabel.fontSize = 30;
    numberOfHitsLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame));
    numberOfHitsLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    [self addChild:numberOfHitsLabel];

    self.numberOfHitsLabel = numberOfHitsLabel;
}

- (void)deployDonutWithUpdate:(CFTimeInterval)currentTime
{
    if (currentTime - self.lastDeployTime < self.deployPeriod) {
        return;
    }


    [self deployDonutAfterDeplay:0];

    if (arc4random() % 4 == 0)
        [self deployDonutAfterDeplay:0.3];

    if (arc4random() % 8 == 0)
        [self deployDonutAfterDeplay:0.6];

    self.lastDeployTime = currentTime;
}

- (void)deployDonutAfterDeplay:(CFTimeInterval)delay
{
    Donut *donut = [self.donutFactory getDonutWithSize:CGSizeMake(64, 64)];
    [self addChild:donut];
    CGPoint point = CGPointMake(arc4random()%(int)self.size.width, arc4random()%(int)self.size.height);

    SKAction *wait = [SKAction waitForDuration:delay];

    SKAction *move = [SKAction moveTo:point duration:0.2];
    move.timingMode = SKActionTimingEaseInEaseOut;
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
                             [self onDonutWillDisappear:donut];
                         }],
                         [SKAction removeFromParent]
                         ];
    SKAction *sequence = [SKAction sequence:actions];
    [donut runAction:sequence];
}

- (void)hitDonut:(Donut *)donut
{
    [donut removeAllActions];
    donut.userInteractionEnabled = NO;
    NSArray *actions = @[
                         [SKAction fadeOutWithDuration:0.2],
                         [SKAction removeFromParent]
                         ];
    SKAction *sequence = [SKAction sequence:actions];
    [donut runAction:sequence];
    self.numberOfHits++;
}

- (void)onDonutWillDisappear:(Donut *)donut
{
    self.numberOfMisses++;
    [self onErrorAtPoint:donut.position];
}

- (void)onErrorAtPoint:(CGPoint)point
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

- (void)setNumberOfMisses:(NSUInteger)numberOfMisses
{
    _numberOfMisses = numberOfMisses;
    self.numberOfMissesLabel.text = [@(numberOfMisses) description];
}

- (void)setNumberOfHits:(NSUInteger)numberOfHits
{
    _numberOfHits = numberOfHits;

    self.numberOfHitsLabel.text = [@(numberOfHits) description];
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        CGPoint point = [touch locationInNode:self];

        SKNode *node = [self nodeAtPoint:point];
        if ([node isKindOfClass:Donut.class]) {
            Donut *donut = (Donut *)node;
            [self hitDonut:donut];
        } else {
            [self onErrorAtPoint:point];
        }
    }];

}

@end
