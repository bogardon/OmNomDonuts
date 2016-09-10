#import <Foundation/Foundation.h>

@interface GameConfig : NSObject

+ (instancetype)sharedConfig;

@property(nonatomic, assign) NSTimeInterval deployPeriod;
@property(nonatomic, assign) NSInteger donutsPerDeploy;
@property(nonatomic, assign) NSInteger maxLives;
@property(nonatomic, assign) CGFloat contractSpeed;

@end
