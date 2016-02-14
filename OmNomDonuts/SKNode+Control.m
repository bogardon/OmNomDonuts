//
//  SKNode+Control.m
//  OmNomDonuts
//
//  Created by jzw on 2/13/16.
//
//

#import "SKNode+Control.h"

#import <objc/runtime.h>

@interface TargetSelectorPair : NSObject
@property(nonatomic, weak) id target;
@property(nonatomic, assign) SEL selector;
@end

@implementation TargetSelectorPair

@end

@interface SKNode ()

@property(nonatomic, readonly) NSMutableArray *targetSelectorPairs;

@end

@implementation SKNode (Control)

- (NSMutableArray *)targetSelectorPairs {
  NSMutableArray *targetSelectorPairs =
      objc_getAssociatedObject(self, @selector(targetSelectorPairs));
  if (!targetSelectorPairs) {
    targetSelectorPairs = [NSMutableArray array];
    objc_setAssociatedObject(self, @selector(targetSelectorPairs), targetSelectorPairs,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return targetSelectorPairs;
}

- (void)addTarget:(id)target selector:(SEL)selector {
  TargetSelectorPair *pair = [[TargetSelectorPair alloc] init];
  pair.target = target;
  pair.selector = selector;
  [self.targetSelectorPairs addObject:pair];
}

- (void)invokeTargets {
  for (TargetSelectorPair *pair in self.targetSelectorPairs) {
    NSMethodSignature *methodSignature =
        [[pair.target class] instanceMethodSignatureForSelector:pair.selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = pair.selector;
    invocation.target = pair.target;
    [invocation setArgument:(__bridge void * _Nonnull)(self) atIndex:2];
    [invocation invoke];
  }
}

@end
