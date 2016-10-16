#import <Foundation/Foundation.h>

@interface GameConfig : NSObject

@property(nonatomic, assign) NSInteger maxLives;
@property(nonatomic, assign) CGFloat gameSpeed;

@property(nonatomic, assign) NSInteger startingNumberOfDonuts;

+ (instancetype)sharedConfig;

- (void)reset;

@end
