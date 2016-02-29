//
//  Donut.h
//  OmNomDonuts
//
//  Created by John Z Wu on 5/18/14.
//
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, DonutState) {
  kDonutStateInitial,
  kDonutStateExpanding,
  kDonutStateContracting,
  kDonutStateHit,
  kDonutStateMissed
};

typedef NS_ENUM(NSInteger, DonutType) {
  kDonutTypeRegular,
  kDonutTypeDecelerator,
  kDonutTypeBlackhole
};

@class Donut;

@protocol DonutStateDelegate<NSObject>

- (void)donutStateDidChange:(Donut *)donut;

@end

@interface Donut : SKSpriteNode

@property(nonatomic, weak) id<DonutStateDelegate> delegate;
@property(nonatomic, readonly) DonutState state;
@property(nonatomic, readonly) DonutType type;
@property(nonatomic, readonly) NSInteger value;

- (instancetype)initWithType:(DonutType)type;
- (void)expandAndContract;
- (void)fadeOut;
- (void)swallow;
- (void)gravitateTowardsPosition:(CGPoint)point;

- (BOOL)isPointWithinSmallestTapRadius:(CGPoint)point;

@end
