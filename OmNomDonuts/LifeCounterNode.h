#import <SpriteKit/SpriteKit.h>

@interface LifeCounterNode : SKNode

- (instancetype)initWithMaxLives:(NSInteger)maxLives;

@property(nonatomic, readonly) NSInteger currentLives;

- (void)reset;

- (void)decrementLives;

@end
