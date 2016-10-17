#import "Donut.h"

@implementation Donut

- (instancetype)init {
  self = [super init];
  if (self) {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
    SKTexture *texture = [atlas textureNamed:self.textureName];
    self.texture = texture;
  }
  return self;
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

  _state = state;
}

@end
