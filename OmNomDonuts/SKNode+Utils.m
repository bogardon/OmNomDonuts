#import "SKNode+Utils.h"

#import "Donut.h"
#import "NSArray+Utils.h"

@implementation SKNode (Utils)

- (NSArray<SKSpriteNode<Donut> *> *)allDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(SKSpriteNode<Donut> *donut) {
    return [donut conformsToProtocol:@protocol(Donut)];
  }];
}

- (NSArray<SKSpriteNode<Donut> *> *)pendingDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(SKSpriteNode<Donut> *donut) {
    return [donut conformsToProtocol:@protocol(Donut)] && !donut.hit;
  }];
}

@end
