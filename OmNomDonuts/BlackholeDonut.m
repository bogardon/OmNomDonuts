//
//  BlackholeDonut.m
//  OmNomDonuts
//
//  Created by jzw on 4/10/16.
//
//

#import "BlackholeDonut.h"

@implementation BlackholeDonut

@synthesize value = _value;
@synthesize contractDuration = _contractDuration;
@synthesize hit = _hit;

- (instancetype)init {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  SKTexture *texture = [atlas textureNamed:@"half_choco_donut"];
  return [self initWithTexture:texture];
}

- (NSInteger)value {
  return 10;
}

- (NSTimeInterval)contractDuration {
  return 2.0;
}

@end
