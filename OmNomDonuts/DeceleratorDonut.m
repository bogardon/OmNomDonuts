#import "DeceleratorDonut.h"

@implementation DeceleratorDonut

- (NSString *)textureName {
  return @"strawberry_donut";
}

- (void)runDeployActions {
  [self removeAllActions];
  [self setScale:0];

  SKAction *pending = [SKAction runBlock:^{
    self.state = kDonutStatePending;
  }];
  SKAction *scaleUp = [SKAction scaleTo:1 duration:0.25];
  scaleUp.timingFunction = ^float(float t) {
    CGFloat f = t - 1.0;
    return 1.0 - f * f * f * f;
  };
  SKAction *wait = [SKAction waitForDuration:2];
  SKAction *scaleDown = [SKAction scaleTo:0 duration:0.25];
  scaleUp.timingFunction = ^float(float t) {
    CGFloat f = t - 1.0;
    return 1.0 - f * f * f * f;
  };
  SKAction *resolved = [SKAction runBlock:^{
    self.state = kDonutStateMissed;
  }];
  NSArray *actions = @[pending, scaleUp, wait, scaleDown, resolved, [SKAction removeFromParent]];
  SKAction *sequence = [SKAction sequence:actions];
  [self runAction:sequence];
}

- (void)runFinishActions {
  [self removeAllActions];

  SKAction *resolved = [SKAction runBlock:^{
    self.state = kDonutStateTapped;
  }];
  NSArray *actions = @[resolved, [SKAction fadeOutWithDuration:0.2], [SKAction removeFromParent]];
  SKAction *sequence = [SKAction sequence:actions];
  [self runAction:sequence];
}

@end
