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
    [self reset];
  }
  return self;
}

#pragma mark Public Methods

- (void)reset {
  _timeToEndingDeployPeriod = 120.0;
  _startingDeployPeriod = 3.0;
  _endingDeployPeriod = 1.0;
  _donutsPerDeploy = 3.0;
  _maxLives = 5;
  _gameSpeed = 1.0;
}

@end
