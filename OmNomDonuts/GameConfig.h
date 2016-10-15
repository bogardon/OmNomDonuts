#import <Foundation/Foundation.h>

@interface GameConfig : NSObject

@property(nonatomic, assign) NSTimeInterval startingDeployPeriod;
@property(nonatomic, assign) NSTimeInterval endingDeployPeriod;
@property(nonatomic, assign) NSInteger donutsPerDeploy;
@property(nonatomic, assign) NSInteger maxLives;
@property(nonatomic, assign) CGFloat gameSpeed;
@property(nonatomic, assign) CGFloat exponentialDecayConstant;

+ (instancetype)sharedConfig;

- (void)reset;

@end
