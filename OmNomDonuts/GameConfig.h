#import <Foundation/Foundation.h>

@interface GameConfig : NSObject

@property(nonatomic, assign) NSTimeInterval deployPeriod;
@property(nonatomic, assign) NSInteger donutsPerDeploy;
@property(nonatomic, assign) CGFloat donutDeployAvgDelay;
@property(nonatomic, assign) NSInteger maxLives;
@property(nonatomic, assign) CGFloat gameSpeed;

+ (instancetype)sharedConfig;

- (void)reset;

@end
