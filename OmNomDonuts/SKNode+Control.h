#import <SpriteKit/SpriteKit.h>

typedef void (^Callback)(SKNode *node);

@interface SKNode (Control)

- (void)addTarget:(id)target selector:(SEL)selector;

- (void)invokeTargets;

- (void)addCallback:(Callback)callback;

@end
