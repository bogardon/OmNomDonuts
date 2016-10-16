#import <Foundation/Foundation.h>

@interface GameConfig : NSObject

@property(nonatomic, assign) NSInteger maxLives;
@property(nonatomic, assign) CGFloat gameSpeed;

@property(nonatomic, assign) NSInteger initialNumberOfDonuts;
@property(nonatomic, assign) NSInteger finalNumberOfDonuts;

@property(nonatomic, assign) CGFloat donutRadius;
@property(nonatomic, assign) CGFloat forgivenessRadius;
@property(nonatomic, assign) NSTimeInterval contractDuration;

+ (instancetype)sharedConfig;

- (void)reset;

@end
