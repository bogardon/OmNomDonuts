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

    Slider *startingDeployPeriodSlider = [[Slider alloc] init];
    startingDeployPeriodSlider.title = @"Starting deploy period";
    startingDeployPeriodSlider.scale = 4;
    startingDeployPeriodSlider.minValue = 3;
    startingDeployPeriodSlider.maxValue = 5;
    startingDeployPeriodSlider.currentValue = [GameConfig sharedConfig].startingDeployPeriod;
    startingDeployPeriodSlider.color = [SKColor redColor];
    CGRect sliderFrame = [startingDeployPeriodSlider calculateAccumulatedFrame];
    startingDeployPeriodSlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMaxY(self.frame) - kPadding - sliderFrame.size.height);
    [self addChild:startingDeployPeriodSlider];
    [startingDeployPeriodSlider addTarget:self selector:@selector(onStartingDeployPeriod:)];

    Slider *endingDeployPeriodSlider = [[Slider alloc] init];
    endingDeployPeriodSlider.title = @"Ending deploy period";
    endingDeployPeriodSlider.scale = 4;
    endingDeployPeriodSlider.minValue = 1;
    endingDeployPeriodSlider.maxValue = 2;
    endingDeployPeriodSlider.currentValue = [GameConfig sharedConfig].endingDeployPeriod;
    endingDeployPeriodSlider.color = [SKColor greenColor];
    endingDeployPeriodSlider.position =
    CGPointMake(CGRectGetMidX(self.frame),
                CGRectGetMidY(startingDeployPeriodSlider.frame) - kPadding - sliderFrame.size.height);
    [self addChild:endingDeployPeriodSlider];
    [endingDeployPeriodSlider addTarget:self selector:@selector(onEndingDeployPeriod:)];

    Slider *exponentialDecayConstantSlider = [[Slider alloc] init];
    exponentialDecayConstantSlider.title = @"Exponential decay constant";
    exponentialDecayConstantSlider.scale = 1;
    exponentialDecayConstantSlider.minValue = 80;
    exponentialDecayConstantSlider.maxValue = 200;
    exponentialDecayConstantSlider.currentValue = [GameConfig sharedConfig].exponentialDecayConstant;
    exponentialDecayConstantSlider.color = [SKColor blueColor];
    exponentialDecayConstantSlider.position =
    CGPointMake(CGRectGetMidX(self.frame),
                CGRectGetMidY(endingDeployPeriodSlider.frame) - kPadding - sliderFrame.size.height);
    [self addChild:exponentialDecayConstantSlider];
    [exponentialDecayConstantSlider addTarget:self selector:@selector(onExponentialDecayConstant:)];

    Slider *donutsPerDeploySlider = [[Slider alloc] init];
    donutsPerDeploySlider.title = @"Donuts per deploy";
    donutsPerDeploySlider.scale = 1;
    donutsPerDeploySlider.minValue = 1;
    donutsPerDeploySlider.maxValue = 10;
    donutsPerDeploySlider.currentValue = [GameConfig sharedConfig].donutsPerDeploy;
    donutsPerDeploySlider.color = [SKColor cyanColor];
    donutsPerDeploySlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMidY(exponentialDecayConstantSlider.frame) - kPadding - sliderFrame.size.height);
    [self addChild:donutsPerDeploySlider];
    [donutsPerDeploySlider addTarget:self selector:@selector(onDonutsPerDeploy:)];


    Slider *maxLivesSlider = [[Slider alloc] init];
    maxLivesSlider.title = @"Max lives";
    maxLivesSlider.scale = 1;
    maxLivesSlider.minValue = 1;
    maxLivesSlider.maxValue = 10;
    maxLivesSlider.currentValue = [GameConfig sharedConfig].maxLives;
    maxLivesSlider.color = [SKColor magentaColor];
    maxLivesSlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMidY(donutsPerDeploySlider.frame) - kPadding - sliderFrame.size.height);
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

- (void)onStartingDeployPeriod:(Slider *)sender {
  [GameConfig sharedConfig].startingDeployPeriod = sender.currentValue;
}

- (void)onEndingDeployPeriod:(Slider *)sender {
  [GameConfig sharedConfig].endingDeployPeriod = sender.currentValue;
}

- (void)onExponentialDecayConstant:(Slider *)sender {
  [GameConfig sharedConfig].exponentialDecayConstant = sender.currentValue;
}

- (void)onDonutsPerDeploy:(Slider *)sender {
  [GameConfig sharedConfig].donutsPerDeploy = sender.currentValue;
}

- (void)onMaxLives:(Slider *)sender {
  [GameConfig sharedConfig].maxLives = sender.currentValue;
}

@end
