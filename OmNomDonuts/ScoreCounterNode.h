#import <SpriteKit/SpriteKit.h>

@interface ScoreCounterNode : SKLabelNode

@property(nonatomic, assign) NSInteger score;

- (void)reset;
- (void)setScore:(NSInteger)score animated:(BOOL)animated;

@end
