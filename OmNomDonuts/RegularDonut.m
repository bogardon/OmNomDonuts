//
//  RegularDonut.m
//  OmNomDonuts
//
//  Created by jzw on 4/10/16.
//
//

#import "RegularDonut.h"

@implementation RegularDonut

@synthesize value = _value;
@synthesize expandAndContractDuration = _expandAndContractDuration;
@synthesize hit = _hit;

- (instancetype)init {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  SKTexture *texture = [atlas textureNamed:@"original_donut"];
  return [self initWithTexture:texture];
}

- (NSInteger)value {
  return 10;
}

- (NSTimeInterval)expandAndContractDuration {
  return 1.2;
}

@end
