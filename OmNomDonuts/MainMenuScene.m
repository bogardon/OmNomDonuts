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

    Slider *startingNumberOfDonutsSlider = [[Slider alloc] init];
    startingNumberOfDonutsSlider.title = @"Starting number of donuts";
    startingNumberOfDonutsSlider.scale = 1;
    startingNumberOfDonutsSlider.minValue = 1;
    startingNumberOfDonutsSlider.maxValue = 6;
    startingNumberOfDonutsSlider.currentValue = [GameConfig sharedConfig].startingNumberOfDonuts;
    startingNumberOfDonutsSlider.color = [SKColor redColor];
    CGRect sliderFrame = [startingNumberOfDonutsSlider calculateAccumulatedFrame];
    startingNumberOfDonutsSlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMaxY(self.frame) - kPadding - sliderFrame.size.height);
    [self addChild:startingNumberOfDonutsSlider];
    [startingNumberOfDonutsSlider addTarget:self selector:@selector(onStartingNumberOfDonuts:)];

    Slider *maxLivesSlider = [[Slider alloc] init];
    maxLivesSlider.title = @"Max lives";
    maxLivesSlider.scale = 1;
    maxLivesSlider.minValue = 1;
    maxLivesSlider.maxValue = 10;
    maxLivesSlider.currentValue = [GameConfig sharedConfig].maxLives;
    maxLivesSlider.color = [SKColor greenColor];
    maxLivesSlider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMidY(startingNumberOfDonutsSlider.frame) - kPadding - sliderFrame.size.height);
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

- (void)onStartingNumberOfDonuts:(Slider *)sender {
  [GameConfig sharedConfig].startingNumberOfDonuts = sender.currentValue;
}

- (void)onMaxLives:(Slider *)sender {
  [GameConfig sharedConfig].maxLives = sender.currentValue;
}

@end
