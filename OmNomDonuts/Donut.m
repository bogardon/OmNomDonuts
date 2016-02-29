//
//  Donut.m
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

#import "Donut.h"

#import "SKScene+Utils.h"

static const CGSize kStandardSize = {60, 60};
static const NSTimeInterval kFadeDuration = 0.2;
static const NSTimeInterval kExpandAndContractDuration = 2;

@interface Donut ()
@property(nonatomic, assign) DonutState state;
@end

@implementation Donut

- (instancetype)initWithType:(DonutType)type {
  self = [super init];
  if (self) {
    _type = type;

    switch (type) {
      case kDonutTypeRegular:
        self.texture = [SKTexture textureWithImageNamed:@"original_donut"];
        break;
      case kDonutTypeDecelerator:
        self.texture = [SKTexture textureWithImageNamed:@"pink_donut"];
        break;
      case kDonutTypeBlackhole:
        self.texture = [SKTexture textureWithImageNamed:@"greyout_donut"];
        break;
    }

    self.size = kStandardSize;
    self.userInteractionEnabled = YES;

    [self expandAndContract];
  }
  return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  self.state = kDonutStateHit;
}

#pragma mark Public Methods

- (NSInteger)value {
  switch (_type) {
    case kDonutTypeRegular:
      return 10;
      break;
    case kDonutTypeDecelerator:
      return 20;
    case kDonutTypeBlackhole:
      return 30;
  }
}

- (void)expandAndContract {
  [self setScale:0];

  SKAction *wait = [SKAction waitForDuration:1.0 withRange:1.0];

  SKAction *scaleUp = [SKAction scaleTo:1 duration:kExpandAndContractDuration];
  SKAction *scaleDown = [SKAction scaleTo:0 duration:kExpandAndContractDuration];

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

- (void)swallow {
  SKAction *fade = [SKAction
      group:@[[SKAction scaleTo:0 duration:0.2], [SKAction fadeOutWithDuration:kFadeDuration]]];
  SKAction *sequence =
      [SKAction sequence:@[[SKAction scaleTo:3 duration:0.2], fade, [SKAction removeFromParent]]];
  [self runAction:sequence];
}

- (void)gravitateTowardsPosition:(CGPoint)point {
  SKAction *group = [SKAction
      group:@[[SKAction moveTo:point duration:0.2], [SKAction fadeOutWithDuration:kFadeDuration]]];
  SKAction *sequence = [SKAction sequence:@[group, [SKAction removeFromParent]]];
  [self runAction:sequence];
}

#pragma mark Private Methods

- (void)setState:(DonutState)state {
  if (_state != state) {
    _state = state;
    if (state == kDonutStateHit) {
      [self removeAllActions];
      self.userInteractionEnabled = NO;

      switch (_type) {
        case kDonutTypeRegular:
          [self fadeOut];
          break;
        case kDonutTypeDecelerator:
          [self fadeOut];
          [self.scene.pendingDonuts
           enumerateObjectsUsingBlock:^(Donut *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
             obj.speed = 0.4;
           }];
          break;
        case kDonutTypeBlackhole:
          [self swallow];
          [self.scene.pendingDonuts
           enumerateObjectsUsingBlock:^(Donut *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
             obj.state = kDonutStateHit;
             [obj gravitateTowardsPosition:self.position];
           }];
          break;
      }
    }
    [_delegate donutStateDidChange:self];
  }
}

@end
