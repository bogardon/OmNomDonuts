#import "DeceleratorDonut.h"

@implementation DeceleratorDonut

@synthesize value = _value;
@synthesize contractDuration = _contractDuration;
@synthesize hit = _hit;

- (instancetype)init {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  SKTexture *texture = [atlas textureNamed:@"strawberry_donut"];
  return [self initWithTexture:texture];
}

- (NSInteger)value {
  return 10;
}

- (NSTimeInterval)contractDuration {
  return 2;
}


@end
