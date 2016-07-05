#import <SpriteKit/SpriteKit.h>

@protocol Donut;

@interface SKNode (Utils)

@property(nonatomic, readonly) NSArray<SKSpriteNode<Donut> *> *allDonuts;
@property(nonatomic, readonly) NSArray<SKSpriteNode<Donut> *> *pendingDonuts;

@end
