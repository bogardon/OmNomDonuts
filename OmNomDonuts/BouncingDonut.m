//
//  BouncingDonut.m
//  OmNomDonuts
//
//  Created by jzw on 4/10/16.
//
//

#import "BouncingDonut.h"

@implementation BouncingDonut

@synthesize value = _value;
@synthesize expandAndContractDuration = _expandAndContractDuration;
@synthesize hit = _hit;

- (instancetype)init {
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Sprites"];
  SKTexture *texture = [atlas textureNamed:@"full_choco_donut"];
  return [self initWithTexture:texture];
}

- (NSInteger)value {
  return 10;
}

- (NSTimeInterval)expandAndContractDuration {
  return 1.2;
}


@end