#import <SpriteKit/SpriteKit.h>

@protocol DonutProtocol;

@interface SKNode (Utils)

@property(nonatomic, readonly) NSArray<SKSpriteNode<DonutProtocol> *> *allDonuts;
@property(nonatomic, readonly) NSArray<SKSpriteNode<DonutProtocol> *> *pendingDonuts;

@end
