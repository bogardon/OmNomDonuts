//
//  SKScene+Utils.m
//  OmNomDonuts
//
//  Created by jzw on 2/18/16.
//
//

#import "SKScene+Utils.h"

#import "Donut.h"
#import "NSArray+Utils.h"

@implementation SKScene (Utils)

- (NSArray<Donut *> *)allDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(Donut *object) {
    return [object isKindOfClass:[Donut class]];
  }];
}

- (NSArray<Donut *> *)pendingDonuts {
  return [self.children filteredArrayWithBlock:^BOOL(Donut *object) {
    return [object isKindOfClass:[Donut class]] &&
           (object.state == kDonutStateExpanding || object.state == kDonutStateContracting);
  }];
}

@end
