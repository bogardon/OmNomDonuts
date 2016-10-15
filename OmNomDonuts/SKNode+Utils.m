#import "SKNode+Utils.h"

#import "DonutProtocol.h"
#import "NSArray+Utils.h"

@implementation SKNode (Utils)

- (NSArray<SKSpriteNode<DonutProtocol> *> *)allDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(SKSpriteNode<DonutProtocol> *donut) {
    return [donut conformsToProtocol:@protocol(DonutProtocol)];
  }];
}

- (NSArray<SKSpriteNode<DonutProtocol> *> *)pendingDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(SKSpriteNode<DonutProtocol> *donut) {
    return [donut conformsToProtocol:@protocol(DonutProtocol)] && !donut.hit;
  }];
}

@end
