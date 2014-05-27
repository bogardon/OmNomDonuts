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

@interface GameScene ()

@property (nonatomic, strong) DonutFactory *donutFactory;

- (void)deployDonut;
- (void)hitDonut:(Donut *)donut;
- (void)missDonutAtPoint:(CGPoint)point;

- (void)createContent;
- (void)onDonutWillDisappear;

- (void)deployDonutWithUpdate:(NSTimeInterval)currentTime;

@property (nonatomic, assign) NSUInteger numberOfMisses;
@property (nonatomic, assign) NSUInteger numberOfHits;

@property (nonatomic, strong) SKLabelNode *numberOfMissesLabel;
@property (nonatomic, strong) SKLabelNode *numberOfHitsLabel;

@property (nonatomic, assign, getter=isContentCreated) BOOL contentCreated;

@property (nonatomic, assign) NSTimeInterval deployPeriod;
@property (nonatomic, assign) NSTimeInterval lastDeployTime;

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

    self.deployPeriod = 1.2;
}

- (void)deployDonutWithUpdate:(NSTimeInterval)currentTime
{
    if (currentTime - self.lastDeployTime < self.deployPeriod) {
        return;
    }

    [self deployDonut];

    self.lastDeployTime = currentTime;
}

- (void)deployDonut
{
    Donut *donut = [self.donutFactory getDonutWithSize:CGSizeMake(64, 64)];
    [self addChild:donut];
    CGPoint point = CGPointMake(arc4random()%(int)self.size.width, arc4random()%(int)self.size.height);

    SKAction *move = [SKAction moveTo:point duration:0.2];
    move.timingMode = SKActionTimingEaseInEaseOut;
    [donut setScale:0.1];

    SKAction *scaleUp = [SKAction scaleTo:1 duration:1.2];
    scaleUp.timingMode = SKActionTimingEaseOut;

    SKAction *scaleDown = [SKAction scaleTo:0 duration:1.2];
    scaleDown.timingMode = SKActionTimingEaseIn;

    SKAction *callBack = [SKAction performSelector:@selector(onDonutWillDisappear) onTarget:self];

    NSArray *actions = @[
                         move,
                         scaleUp,
                         scaleDown,
                         callBack,
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

- (void)missDonutAtPoint:(CGPoint)point
{
    self.numberOfMisses++;
}

- (void)onDonutWillDisappear
{
    self.numberOfMisses++;
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

    switch (numberOfHits) {
        case 10:
            self.deployPeriod = 1;
            break;
        case 20:
            self.deployPeriod = 0.8;
            break;
        case 30:
            self.deployPeriod = 0.6;
            break;
        case 40:
            self.deployPeriod = 0.5;
            break;
        case 50:
            self.deployPeriod = 0.45;
            break;
        case 60:
            self.deployPeriod = 0.4;
            break;
        case 70:
            self.deployPeriod = 0.37;
            break;
        case 80:
            self.deployPeriod = 0.35;
            break;
        default:
            break;
    }
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
        }
    }];

}

@end
