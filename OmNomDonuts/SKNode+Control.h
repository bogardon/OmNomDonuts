#import <SpriteKit/SpriteKit.h>

@interface SKNode (Control)

- (void)addTarget:(id)target selector:(SEL)selector;

- (void)invokeTargets;

@end
