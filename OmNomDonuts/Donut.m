#import "Donut.h"

@interface Donut ()

@property(nonatomic, assign) DonutState state;

@end

@implementation Donut

#pragma mark Public Methods

- (NSString *)textureName {
  return nil;
}

- (void)runDeployActions {
  // No op.
}

- (void)runFinishActions {
  // No op.
}

#pragma mark Private Methods

- (void)setState:(DonutState)state {
  [self.delegate donutWillTransitionState:self oldState:_state newState:state];

  _state = state;
}

@end
