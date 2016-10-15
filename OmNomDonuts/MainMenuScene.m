#import "GameScene.h"

#import "MainMenuScene.h"
#import "SKNode+Control.h"
#import "ViewController.h"
#import "PlayNode.h"
#import "Slider.h"
#import "GameConfig.h"

static const CGFloat kPadding = 16.0;

@interface MainMenuScene ()
@end

@implementation MainMenuScene

- (id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];

    PlayNode *play = [[PlayNode alloc] init];
    play.userInteractionEnabled = YES;
    play.position = CGPointMake(CGRectGetMidX(self.frame),
                                kPadding + play.size.height / 2);
    [self addChild:play];
    [play addTarget:self selector:@selector(onPlay:)];

    Slider *deployPeriodSlider = [[Slider alloc] init];
    deployPeriodSlider.title = @"Deploy period";
    deployPeriodSlider.scale = 2;
    deployPeriodSlider.minValue = 1;
    deployPeriodSlider.maxValue = 10;
    deployPeriodSlider.currentValue = [GameConfig sharedConfig].deployPeriod;
    deployPeriodSlider.color = [SKColor redColor];
    CGRect sliderFrame = [deployPeriodSlider calculateAccumulatedFrame];
    deployPeriodSlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMaxY(self.frame) - kPadding - sliderFrame.size.height);
    [self addChild:deployPeriodSlider];
    [deployPeriodSlider addTarget:self selector:@selector(onDeployPeriod:)];

    Slider *donutsPerDeploySlider = [[Slider alloc] init];
    donutsPerDeploySlider.title = @"Donuts per deploy";
    donutsPerDeploySlider.scale = 1;
    donutsPerDeploySlider.minValue = 1;
    donutsPerDeploySlider.maxValue = 10;
    donutsPerDeploySlider.currentValue = [GameConfig sharedConfig].donutsPerDeploy;
    donutsPerDeploySlider.color = [SKColor greenColor];
    donutsPerDeploySlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMidY(deployPeriodSlider.frame) - kPadding - sliderFrame.size.height);
    [self addChild:donutsPerDeploySlider];
    [donutsPerDeploySlider addTarget:self selector:@selector(onDonutsPerDeploy:)];

    Slider *donutDeployAvgDelaySlider = [[Slider alloc] init];
    donutDeployAvgDelaySlider.title = @"Donut deploy average delay";
    donutDeployAvgDelaySlider.scale = 4;
    donutDeployAvgDelaySlider.minValue = 0;
    donutDeployAvgDelaySlider.maxValue = 1.5;
    donutDeployAvgDelaySlider.currentValue = [GameConfig sharedConfig].donutDeployAvgDelay;
    donutDeployAvgDelaySlider.color = [SKColor blueColor];
    donutDeployAvgDelaySlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMidY(donutsPerDeploySlider.frame) - kPadding - sliderFrame.size.height);
    [self addChild:donutDeployAvgDelaySlider];
    [donutDeployAvgDelaySlider addTarget:self selector:@selector(onDonutDeplyAvgDelay:)];

    Slider *maxLivesSlider = [[Slider alloc] init];
    maxLivesSlider.title = @"Max lives";
    maxLivesSlider.scale = 1;
    maxLivesSlider.minValue = 1;
    maxLivesSlider.maxValue = 10;
    maxLivesSlider.currentValue = [GameConfig sharedConfig].maxLives;
    maxLivesSlider.color = [SKColor yellowColor];
    maxLivesSlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMidY(donutDeployAvgDelaySlider.frame) - kPadding - sliderFrame.size.height);
    [self addChild:maxLivesSlider];
    [maxLivesSlider addTarget:self selector:@selector(onMaxLives:)];
  }
  return self;
}

#pragma mark Private Methods

- (void)onPlay:(id)sender {
  GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
  gameScene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition crossFadeWithDuration:0.5];
  [self.view presentScene:gameScene transition:transition];
}

- (void)onDeployPeriod:(Slider *)sender {
  [GameConfig sharedConfig].deployPeriod = sender.currentValue;
}

- (void)onDonutsPerDeploy:(Slider *)sender {
  [GameConfig sharedConfig].donutsPerDeploy = sender.currentValue;
}

- (void)onDonutDeplyAvgDelay:(Slider *)sender {
  [GameConfig sharedConfig].donutDeployAvgDelay = sender.currentValue;
}

- (void)onMaxLives:(Slider *)sender {
  [GameConfig sharedConfig].maxLives = sender.currentValue;
}

@end
