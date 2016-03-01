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
static const CGFloat kSmallestTapRadius = 10.0;
static const NSTimeInterval kFadeDuration = 0.2;
static const NSTimeInterval kExpandAndContractDuration = 2;
static NSString *const kExpandAndContractActionKey = @"kExpandAndContractActionKey";
static const CGFloat kBlackholeRadius = 120.0;

@interface Donut ()
@property(nonatomic, assign) DonutState state;
@end

@implementation Donut

- (instancetype)initWithType:(DonutType)type {
  self = [super init];
  if (self) {
    _type = type;

    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
    switch (type) {
      case kDonutTypeRegular:
        self.texture = [atlas textureNamed:@"original_donut"];
        break;
      case kDonutTypeDecelerator:
        self.texture = [atlas textureNamed:@"strawberry_donut"];
        break;
      case kDonutTypeBlackhole:
        self.texture = [atlas textureNamed:@"half_choco_donut"];
        break;
    }

    self.size = kStandardSize;
    self.userInteractionEnabled = YES;

    [self expandAndContract];
  }
  return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  self.state = kDonutStateHit;

  switch (_type) {
    case kDonutTypeRegular:
      [self fadeOut];
      break;
    case kDonutTypeDecelerator:
      [self fadeOut];
      [self.scene.pendingDonuts
          enumerateObjectsUsingBlock:^(Donut *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [obj slowDown];
          }];
      break;
    case kDonutTypeBlackhole:
      [self swallow];
      [self.scene.pendingDonuts
          enumerateObjectsUsingBlock:^(Donut *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (hypot(obj.position.x - self.position.x, obj.position.y - self.position.y) <
                kBlackholeRadius) {
              obj.state = kDonutStateHit;
              [obj gravitateTowardsPosition:self.position];
            }
          }];
      break;
  }
}

#pragma mark Public Methods

- (BOOL)isPointWithinSmallestTapRadius:(CGPoint)point {
  return hypot(point.x - self.position.x, point.y - self.position.y) <= kSmallestTapRadius;
}

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

  SKAction *wait = [SKAction waitForDuration:2.0 withRange:4.0];

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
  [self runAction:sequence withKey:kExpandAndContractActionKey];
}

- (void)slowDown {
  [self actionForKey:kExpandAndContractActionKey].speed = 0.4;
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
    }
    [_delegate donutStateDidChange:self];
  }
}

@end
