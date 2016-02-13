//
//  Donut.m
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

#import "Donut.h"

@implementation Donut

+ (SKTexture *)donutTexture {
  static SKTexture *donutTexture = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    donutTexture = [SKTexture textureWithImageNamed:@"donut2"];
  });
  return donutTexture;
}

@end
