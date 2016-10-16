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
  _contractDuration = 4.0;
  _donutRadius = 60.0;
  _forgivenessRadius = 10.0;
  _initialNumberOfDonuts = 1;
  _finalNumberOfDonuts = 8;
  _maxLives = 5;
  _gameSpeed = 1.0;
}

@end
