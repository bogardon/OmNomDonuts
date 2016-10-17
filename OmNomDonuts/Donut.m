#import "Donut.h"

@implementation Donut

- (instancetype)init {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  SKTexture *texture = [atlas textureNamed:self.textureName];
  self.state = kDonutStateInitialized;
  return [self initWithTexture:texture];
}

#pragma mark Public Methods

- (NSString *)textureName {
  return nil;
}

- (void)runDeployActions {
  // No op.
}

- (void)runFinishActions {
  // No op.
}

#pragma mark Private Methods

- (void)setState:(DonutState)state {
  [self.delegate donutWillTransitionState:self oldState:_state newState:state];

  self.userInteractionEnabled = state == kDonutStateMissed || state == kDonutStateTapped;

  _state = state;
}

@end
