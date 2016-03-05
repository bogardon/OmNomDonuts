//
//  Difficulty.m
//  OmNomDonuts
//
//  Created by jzw on 2/29/16.
//
//

#import "GameConfig.h"

@implementation GameConfig

- (instancetype)init {
  self = [super init];
  if (self) {
    _deployPeriod = 3.0;
    _numberOfDonutsPerDeploy = 3;
    _maxLives = 5;
  }
  return self;
}

@end
