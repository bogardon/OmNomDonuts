//
//  NSArray+Utils.m
//  OmNomDonuts
//
//  Created by jzw on 2/16/16.
//
//

#import "NSArray+Utils.h"

@implementation NSArray (Utils)

- (NSArray *)filteredArrayWithBlock:(FilterBlock)block {
  return
      [self filteredArrayUsingPredicate:[NSPredicate
                                            predicateWithBlock:^BOOL(
                                                id _Nonnull evaluatedObject,
                                                NSDictionary<NSString *, id> *_Nullable bindings) {
                                              return block(evaluatedObject);
                                            }]];
}

@end
