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
@property(nonatomic, readonly) NSMutableArray *callbacks;;

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

- (NSMutableArray *)callbacks {
  NSMutableArray *callbacks = objc_getAssociatedObject(self, @selector(callbacks));
  if (!callbacks) {
    callbacks = [NSMutableArray array];
    objc_setAssociatedObject(self,
                             @selector(callbacks),
                             callbacks,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return callbacks;
}

- (void)addTarget:(id)target selector:(SEL)selector {
  TargetSelectorPair *pair = [[TargetSelectorPair alloc] init];
  pair.target = target;
  pair.selector = selector;
  [self.targetSelectorPairs addObject:pair];
}

- (void)addCallback:(Callback)callback {
  [self.callbacks addObject:callback];
}

- (void)invokeTargets {
  for (TargetSelectorPair *pair in self.targetSelectorPairs) {
    NSMethodSignature *methodSignature =
        [[pair.target class] instanceMethodSignatureForSelector:pair.selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = pair.selector;
    invocation.target = pair.target;
    SKNode *node = self;
    if (methodSignature.numberOfArguments >= 3) {
      [invocation setArgument:&node atIndex:2];
    }
    [invocation invoke];
  }

  for (Callback callback in self.callbacks) {
    callback(self);
  }
}

@end
