#import "GameConfig.h"

@implementation GameConfig

+ (instancetype)sharedConfig {
  static GameConfig *config = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    config = [[GameConfig alloc] init];
  });
  return config;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _deployPeriod = 3.0;
    _donutsPerDeploy = 3;
    _maxLives = 5;
    _contractSpeed = 1.0;
  }
  return self;
}

@end
