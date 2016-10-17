#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, DonutState) {
  kDonutStateInitialized,
  kDonutStatePending,
  kDonutStateResolved,
};

@protocol DonutDelegate;

/** Abstract base class for a donut. */
@interface Donut : SKSpriteNode

@property(nonatomic, readonly) NSString *textureName;
@property(nonatomic, readonly) DonutState state;
@property(nonatomic, weak) id<DonutDelegate> delegate;

- (void)runDeployActions;
- (void)runFinishActions;

@end

@protocol DonutDelegate<NSObject>

- (void)donutWillTransitionState:(Donut *)donut
                        oldState:(DonutState)oldState
                        newState:(DonutState)newState;
`
@end
