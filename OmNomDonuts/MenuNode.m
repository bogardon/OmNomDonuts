#import "MenuNode.h"

#import "SKNode+Control.h"

@implementation MenuNode

- (instancetype)init {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  SKTexture *texture = [atlas textureNamed:@"menu"];
  return [self initWithTexture:texture];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  [self invokeTargets];
}

@end
