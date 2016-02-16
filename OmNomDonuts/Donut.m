//
//  Donut.m
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

#import "Donut.h"

#import "SKNode+Control.h"

static const CGSize kStandardSize = {40, 40};
static const NSTimeInterval kFadeDuration = 0.2;
static const NSTimeInterval kExpandAndContractDuration = 2;

@interface Donut ()
@property(nonatomic, assign) DonutState state;
@end

@implementation Donut

- (instancetype)initWithType:(DonutType)donutType {
  self = [super init];
  if (self) {
    switch (donutType) {
      case kDonutTypeRegular:
        self.texture = [SKTexture textureWithImageNamed:@"donut2.png"];
        break;
      case kDonutTypeDecelerator:
        self.texture = [SKTexture textureWithImageNamed:@"pink_donut.png"];
        break;
      case kDonutTypeBlackhole:
        break;
    }

    self.size = kStandardSize;
    self.userInteractionEnabled = YES;
  }
  return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self removeAllActions];
  self.userInteractionEnabled = NO;
  self.state = kDonutStateHit;
}

#pragma mark Public Methods

- (void)expandAndContract {
  [self setScale:0];

  SKAction *wait = [SKAction waitForDuration:1.0 withRange:1.0];

  SKAction *scaleUp = [SKAction scaleTo:1 duration:kExpandAndContractDuration];
  scaleUp.timingMode = SKActionTimingEaseOut;

  SKAction *scaleDown = [SKAction scaleTo:0 duration:kExpandAndContractDuration];
  scaleDown.timingMode = SKActionTimingEaseIn;

  NSArray *actions = @[
    wait,
    [SKAction runBlock:^{
      self.state = kDonutStateExpanding;
    }],
    scaleUp,
    [SKAction runBlock:^{
      self.state = kDonutStateContracting;
    }],
    scaleDown,
    [SKAction runBlock:^{
      self.state = kDonutStateMissed;
    }],
    [SKAction removeFromParent]
  ];
  SKAction *sequence = [SKAction sequence:actions];
  [self runAction:sequence];
}

- (void)fadeOut {
  NSArray *actions = @[[SKAction fadeOutWithDuration:kFadeDuration], [SKAction removeFromParent]];
  SKAction *sequence = [SKAction sequence:actions];
  [self runAction:sequence];
}

#pragma mark Private Methods

- (void)setState:(DonutState)state {
  if (_state != state) {
    _state = state;
    [_delegate donutStateDidChange:self];
  }
}

@end
