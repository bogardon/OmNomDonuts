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

    Slider *slider = [[Slider alloc] init];
    slider.title = @"Initial number of donuts";
    slider.scale = 1;
    slider.minValue = 1;
    slider.maxValue = 5;
    slider.currentValue = [GameConfig sharedConfig].initialNumberOfDonuts;
    slider.color = [SKColor redColor];
    CGRect sliderFrame = [slider calculateAccumulatedFrame];
    slider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    CGRectGetMaxY(self.frame) - kPadding - sliderFrame.size.height);
    [self addChild:slider];
    [slider addTarget:self selector:@selector(onInitialNumberOfDonuts:)];
    CGFloat lastSliderY = CGRectGetMidY(slider.frame);

    slider = [[Slider alloc] init];
    slider.title = @"Final number of donuts";
    slider.scale = 1;
    slider.minValue = 6;
    slider.maxValue = 12;
    slider.currentValue = [GameConfig sharedConfig].finalNumberOfDonuts;
    slider.color = [SKColor blueColor];
    slider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    lastSliderY - kPadding - sliderFrame.size.height);
    [self addChild:slider];
    [slider addTarget:self selector:@selector(onFinalNumberOfDonuts:)];
    lastSliderY = CGRectGetMidY(slider.frame);

    slider = [[Slider alloc] init];
    slider.title = @"Max lives";
    slider.scale = 1;
    slider.minValue = 1;
    slider.maxValue = 10;
    slider.currentValue = [GameConfig sharedConfig].maxLives;
    slider.color = [SKColor greenColor];
    slider.position =
        CGPointMake(CGRectGetMidX(self.frame),
                    lastSliderY - kPadding - sliderFrame.size.height);
    [self addChild:slider];
    [slider addTarget:self selector:@selector(onMaxLives:)];
    lastSliderY = CGRectGetMidY(slider.frame);

    slider = [[Slider alloc] init];
    slider.title = @"Donut radius";
    slider.scale = 1;
    slider.minValue = 40;
    slider.maxValue = 80;
    slider.currentValue = [GameConfig sharedConfig].donutRadius;
    slider.color = [SKColor cyanColor];
    slider.position =
    CGPointMake(CGRectGetMidX(self.frame),
                lastSliderY - kPadding - sliderFrame.size.height);
    [self addChild:slider];
    [slider addTarget:self selector:@selector(onDonutRadius:)];
    lastSliderY = CGRectGetMidY(slider.frame);

    slider = [[Slider alloc] init];
    slider.title = @"Forgiveness radius";
    slider.scale = 1;
    slider.minValue = 0;
    slider.maxValue = 30;
    slider.currentValue = [GameConfig sharedConfig].forgivenessRadius;
    slider.color = [SKColor magentaColor];
    slider.position =
    CGPointMake(CGRectGetMidX(self.frame),
                lastSliderY - kPadding - sliderFrame.size.height);
    [self addChild:slider];
    [slider addTarget:self selector:@selector(onForgivenessRadius:)];
    lastSliderY = CGRectGetMidY(slider.frame);

    slider = [[Slider alloc] init];
    slider.title = @"Contraction duration";
    slider.scale = 2;
    slider.minValue = 2.0;
    slider.maxValue = 8.0;
    slider.currentValue = [GameConfig sharedConfig].contractDuration;
    slider.color = [SKColor yellowColor];
    slider.position =
    CGPointMake(CGRectGetMidX(self.frame),
                lastSliderY - kPadding - sliderFrame.size.height);
    [self addChild:slider];
    [slider addTarget:self selector:@selector(onContractDuration:)];
    lastSliderY = CGRectGetMidY(slider.frame);
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

- (void)onInitialNumberOfDonuts:(Slider *)sender {
  [GameConfig sharedConfig].initialNumberOfDonuts = sender.currentValue;
}

- (void)onFinalNumberOfDonuts:(Slider *)sender {
  [GameConfig sharedConfig].finalNumberOfDonuts = sender.currentValue;
}

- (void)onMaxLives:(Slider *)sender {
  [GameConfig sharedConfig].maxLives = sender.currentValue;
}

- (void)onDonutRadius:(Slider *)sender {
  [GameConfig sharedConfig].donutRadius = sender.currentValue;
}

- (void)onForgivenessRadius:(Slider *)sender {
  [GameConfig sharedConfig].forgivenessRadius = sender.currentValue;
}

- (void)onContractDuration:(Slider *)sender {
  [GameConfig sharedConfig].contractDuration = sender.currentValue;
}

@end
