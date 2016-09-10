#import "GameScene.h"

#import "MainMenuScene.h"
#import "SKNode+Control.h"
#import "ViewController.h"
#import "PlayNode.h"
#import "Slider.h"
#import "GameConfig.h"

@interface MainMenuScene ()
@end

@implementation MainMenuScene {
  Slider *_deployPeriodSlider;
  Slider *_donutsPerDeploySlider;
  Slider *_maxLivesSlider;
}

- (id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];

    PlayNode *play = [[PlayNode alloc] init];
    play.userInteractionEnabled = YES;
    play.position = CGPointMake(CGRectGetMidX(self.frame),
                                CGRectGetMidY(self.frame));
    [self addChild:play];
    [play addTarget:self selector:@selector(onPlay:)];

    _deployPeriodSlider = [[Slider alloc] init];
    _deployPeriodSlider.title = @"Deploy period";
    _deployPeriodSlider.scale = 2;
    _deployPeriodSlider.minValue = 1;
    _deployPeriodSlider.maxValue = 10;
    _deployPeriodSlider.currentValue = [GameConfig sharedConfig].deployPeriod;
    _deployPeriodSlider.color = [SKColor redColor];
    _deployPeriodSlider.position = CGPointMake(CGRectGetMidX(self.frame),
                                               CGRectGetMidY(self.frame) - 70);
    [self addChild:_deployPeriodSlider];
    [_deployPeriodSlider addTarget:self selector:@selector(onDeployPeriod:)];

    _donutsPerDeploySlider = [[Slider alloc] init];
    _donutsPerDeploySlider.title = @"Donuts per deploy";
    _donutsPerDeploySlider.scale = 1;
    _donutsPerDeploySlider.minValue = 1;
    _donutsPerDeploySlider.maxValue = 10;
    _donutsPerDeploySlider.currentValue = [GameConfig sharedConfig].donutsPerDeploy;
    _donutsPerDeploySlider.color = [SKColor greenColor];
    _donutsPerDeploySlider.position = CGPointMake(CGRectGetMidX(self.frame),
                                                  CGRectGetMidY(_deployPeriodSlider.frame) - 50);
    [self addChild:_donutsPerDeploySlider];
    [_donutsPerDeploySlider addTarget:self selector:@selector(onDonutsPerDeploy:)];

    _maxLivesSlider = [[Slider alloc] init];
    _maxLivesSlider.title = @"Max lives";
    _maxLivesSlider.scale = 1;
    _maxLivesSlider.minValue = 1;
    _maxLivesSlider.maxValue = 10;
    _maxLivesSlider.currentValue = [GameConfig sharedConfig].maxLives;
    _maxLivesSlider.color = [SKColor blueColor];
    _maxLivesSlider.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(_donutsPerDeploySlider.frame) - 50);
    [self addChild:_maxLivesSlider];
    [_maxLivesSlider addTarget:self selector:@selector(onMaxLives:)];

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

- (void)onDeployPeriod:(id)sender {
  [GameConfig sharedConfig].deployPeriod = _deployPeriodSlider.currentValue;
}

- (void)onDonutsPerDeploy:(id)sender {
  [GameConfig sharedConfig].donutsPerDeploy = _donutsPerDeploySlider.currentValue;
}

- (void)onMaxLives:(id)sender {
  [GameConfig sharedConfig].maxLives = _maxLivesSlider.currentValue;
}

@end
