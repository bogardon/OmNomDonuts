#import "RegularDonut.h"

@implementation RegularDonut

@synthesize value = _value;
@synthesize contractDuration = _contractDuration;
@synthesize hit = _hit;

- (instancetype)init {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  SKTexture *texture = [atlas textureNamed:@"regular_donut"];
  return [self initWithTexture:texture];
}

- (NSInteger)value {
  return 10;
}

- (NSTimeInterval)contractDuration {
  return 4;
}

@end
